
import XCTest

final class EasyBankSteps {

    private let app: XCUIApplication
    private let page: EasyBankPage

    init(app: XCUIApplication) {
        self.app = app
        self.page = EasyBankPage(app: app)
    }

    // MARK: - Common Helpers

    private func tap(_ element: XCUIElement) {
        guard element.waitForExistence(timeout: 15) else {
            XCTFail("Element was not found: \(element)")
            return
        }

        if !element.isHittable {
            dismissKeyboard()
        }

        guard element.isHittable else {
            XCTFail("Element is not hittable: \(element)")
            return
        }

        element.tap()
    }

    private func enterText(
        _ text: String,
        into element: XCUIElement
    ) {
        guard element.waitForExistence(timeout: 15) else {
            XCTFail("Text field was not found: \(element)")
            return
        }

        tap(element)

        guard element.isHittable else {
            XCTFail("Text field is not hittable: \(element)")
            return
        }

        if let currentValue = element.value as? String,
           !currentValue.isEmpty,
           currentValue != element.placeholderValue {

            let deleteString = String(
                repeating: XCUIKeyboardKey.delete.rawValue,
                count: currentValue.count
            )

            element.typeText(deleteString)
        }

        element.typeText(text)
    }

    private func dismissKeyboard() {
        let keyboard = app.keyboards.firstMatch

        guard keyboard.exists else { return }

        let doneButton = keyboard.buttons["Done"]
        let returnButton = keyboard.buttons["Return"]

        if doneButton.exists && doneButton.isHittable {
            doneButton.tap()
        } else if returnButton.exists && returnButton.isHittable {
            returnButton.tap()
        } else {
            app.swipeDown()
        }
    }

    private func dismissStrongPasswordPromptIfPresent() {
        let closeButton = app.buttons["Close"]

        if closeButton.waitForExistence(timeout: 2),
           closeButton.isHittable {
            closeButton.tap()
        }
    }

    // MARK: - Password Visibility

    private func enterVisiblePassword(
        _ password: String,
        secureField: XCUIElement,
        visibilityButton: XCUIElement,
        visibleField: XCUIElement
    ) {
        guard secureField.waitForExistence(timeout: 15) else {
            XCTFail("Password field was not found")
            return
        }

        tap(secureField)
        dismissStrongPasswordPromptIfPresent()

        // The reference shows a nested button labeled "hide".
        // Tapping it is expected to change password visibility.
        if visibilityButton.exists && visibilityButton.isHittable {
            visibilityButton.tap()
        }

        if visibleField.waitForExistence(timeout: 5) {
            enterText(password, into: visibleField)
        } else {
            // Fallback when the control remains a SecureTextField.
            enterText(password, into: secureField)
        }
    }

    // MARK: - Onboarding

    func openLoginScreen() {
        tap(page.onboardingLoginButton)

        XCTAssertTrue(
            page.loginEmailField.waitForExistence(timeout: 15),
            "Login screen was not displayed"
        )
    }

    func openRegistrationScreen() {
        tap(page.onboardingRegisterButton)

        XCTAssertTrue(
            page.registrationEmailField.waitForExistence(timeout: 15),
            "Registration screen was not displayed"
        )
    }

    // MARK: - Login

    func enterLoginEmail(_ email: String) {
        enterText(email, into: page.loginEmailField)
    }

    func enterLoginPassword(_ password: String) {
        enterVisiblePassword(
            password,
            secureField: page.loginPasswordField,
            visibilityButton: page.loginPasswordVisibilityButton,
            visibleField: page.visibleLoginPasswordField
        )
    }

    func submitLogin() {
        dismissKeyboard()
        tap(page.loginSubmitButton)
    }

    func login(email: String, password: String) {
        enterLoginEmail(email)
        enterLoginPassword(password)
        submitLogin()
    }

    // MARK: - Login Assertions

    func verifyInvalidEmailError() {
        verifyLoginError(contains: "badly formatted")
    }

    func verifyInvalidCredentialsError() {
        verifyLoginError(
            contains: "malformed or has expired"
        )
    }

    private func verifyLoginError(contains text: String) {
        let error = page.loginErrorMessage

        guard error.waitForExistence(timeout: 15) else {
            XCTFail("Authentication error was not displayed")
            return
        }

        XCTAssertTrue(
            error.label.localizedCaseInsensitiveContains(text),
            "Expected '\(text)', got '\(error.label)'"
        )
    }

    // MARK: - Registration

    func enterRegistrationEmail(_ email: String) {
        enterText(email, into: page.registrationEmailField)
    }

    func enterRegistrationPassword(_ password: String) {
        enterVisiblePassword(
            password,
            secureField: page.registrationPasswordField,
            visibilityButton: page.registrationPasswordVisibilityButton,
            visibleField: page.visibleRegistrationPasswordField
        )
    }

    func enterRepeatPassword(_ password: String) {
        enterVisiblePassword(
            password,
            secureField: page.registrationRepeatPasswordField,
            visibilityButton: page.repeatPasswordVisibilityButton,
            visibleField: page.visibleRepeatPasswordField
        )
    }

    func submitRegistration() {
        dismissKeyboard()
        tap(page.registrationSubmitButton)
    }

    func register(email: String, password: String) {
        enterRegistrationEmail(email)
        enterRegistrationPassword(password)
        enterRepeatPassword(password)
        submitRegistration()
    }

    // MARK: - Home

    func verifyHomeScreen() {
        XCTAssertTrue(
            page.sendMoneyButton.waitForExistence(timeout: 20),
            "Home screen was not displayed"
        )
    }

    // MARK: - Logout

    func logout() {
        tap(page.logoutButton)

        guard page.logoutAlert.waitForExistence(timeout: 10) else {
            XCTFail("Logout alert was not displayed")
            return
        }

        tap(page.confirmLogoutButton)

        XCTAssertTrue(
            page.loginEmailField.waitForExistence(timeout: 15),
            "Login screen was not displayed after logout"
        )
    }

    // MARK: - Reusable Flow

    func registerLogoutAndLogin(
        email: String,
        password: String
    ) {
        openRegistrationScreen()

        register(email: email, password: password)

        verifyHomeScreen()

        logout()

        login(email: email, password: password)

        verifyHomeScreen()
    }
}
