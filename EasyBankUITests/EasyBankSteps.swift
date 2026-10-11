
import XCTest

final class EasyBankSteps {

    private let app: XCUIApplication
    private let page: EasyBankPage

    init(app: XCUIApplication) {
        self.app = app
        self.page = EasyBankPage(app: app)
    }

    // MARK: - Common Helpers

    @discardableResult
    private func tap(_ element: XCUIElement) -> Bool {
        guard element.waitForExistence(timeout: 15) else {
            XCTFail("Element was not found: \(element)")
            return false
        }

        if !element.isHittable {
            dismissKeyboard()
        }

        guard element.isHittable else {
            XCTFail("Element is not hittable: \(element)")
            return false
        }

        element.tap()
        return true
    }

    private func enterText(
        _ text: String,
        into element: XCUIElement
    ) {
        guard tap(element) else { return }

        if let currentValue = element.value as? String,
           !currentValue.isEmpty,
           currentValue != element.placeholderValue {

            let deleteText = String(
                repeating: XCUIKeyboardKey.delete.rawValue,
                count: currentValue.count
            )

            element.typeText(deleteText)
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
        }
    }

    // MARK: - Strong Password

    private func dismissStrongPasswordPromptIfPresent() {
        let closeButton = app.buttons["Close"]

        if closeButton.waitForExistence(timeout: 2),
           closeButton.isHittable {
            closeButton.tap()
        }
    }

    // MARK: - Login Password
    // Preserve the previously passing login behavior.

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

        guard tap(secureField) else { return }

        dismissStrongPasswordPromptIfPresent()

        guard visibilityButton.waitForExistence(timeout: 10),
              visibilityButton.isHittable else {
            XCTFail("Password visibility button was not found")
            return
        }

        visibilityButton.tap()

        guard visibleField.waitForExistence(timeout: 10) else {
            XCTFail("Visible password field was not found")
            return
        }

        guard visibleField.isHittable else {
            XCTFail("Visible password field is not hittable")
            return
        }

        visibleField.tap()
        visibleField.typeText(password)

        XCTAssertEqual(
            visibleField.value as? String,
            password,
            "Password was not entered correctly"
        )
    }

    // MARK: - Registration Password

    private func enterRegistrationPasswordWithRecovery(
        _ password: String,
        identifier: String
    ) {
        let secureField = app.secureTextFields[identifier]

        guard secureField.waitForExistence(timeout: 15) else {
            XCTFail("Registration password field not found: \(identifier)")
            return
        }

        guard tap(secureField) else { return }

        dismissStrongPasswordPromptIfPresent()

        let visibilityButton = secureField.buttons["hide"]

        guard visibilityButton.waitForExistence(timeout: 10),
              visibilityButton.isHittable else {
            XCTFail("Visibility button not found: \(identifier)")
            return
        }

        visibilityButton.tap()

        var visibleField = app.textFields[identifier]

        guard visibleField.waitForExistence(timeout: 10) else {
            XCTFail("Visible password field not found: \(identifier)")
            return
        }

        guard tap(visibleField) else { return }

        // Enter the password in one operation first.
        visibleField.typeText(password)

        // Re-query after SwiftUI updates the field.
        visibleField = app.textFields[identifier]

        if visibleField.value as? String == password {
            return
        }

        // Recover if only a prefix was entered.
        for _ in 0..<3 {
            visibleField = app.textFields[identifier]

            guard visibleField.waitForExistence(timeout: 5) else {
                break
            }

            guard let currentValue = visibleField.value as? String else {
                break
            }

            if currentValue == password {
                return
            }

            guard password.hasPrefix(currentValue),
                  currentValue.count < password.count else {
                break
            }

            let remaining = String(
                password.dropFirst(currentValue.count)
            )

            guard tap(visibleField) else { return }

            visibleField.typeText(remaining)

            if app.textFields[identifier].value as? String == password {
                return
            }
        }

        visibleField = app.textFields[identifier]

        XCTAssertEqual(
            visibleField.value as? String,
            password,
            "Registration password was not entered correctly: \(identifier)"
        )
    }

    // MARK: - Onboarding

    func openLoginScreen() {
        guard tap(page.onboardingLoginButton) else { return }

        XCTAssertTrue(
            page.loginEmailField.waitForExistence(timeout: 15),
            "Login screen was not displayed"
        )
    }

    func openRegistrationScreen() {
        guard tap(page.onboardingRegisterButton) else { return }

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
        verifyLoginError(contains: "malformed or has expired")
    }

    private func verifyLoginError(contains expectedText: String) {
        let error = page.loginErrorMessage

        guard error.waitForExistence(timeout: 15) else {
            XCTFail("Login error was not displayed")
            return
        }

        XCTAssertTrue(
            error.label.localizedCaseInsensitiveContains(expectedText),
            "Unexpected login error: \(error.label)"
        )
    }

    // MARK: - Registration

    func enterRegistrationEmail(_ email: String) {
        enterText(email, into: page.registrationEmailField)
    }

    func enterRegistrationPassword(_ password: String) {
        enterRegistrationPasswordWithRecovery(
            password,
            identifier: "registration.password"
        )
    }

    func enterRepeatPassword(_ password: String) {
        enterRegistrationPasswordWithRecovery(
            password,
            identifier: "registration.repeatPassword"
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
        guard tap(page.logoutButton) else { return }

        guard page.logoutAlert.waitForExistence(timeout: 10) else {
            XCTFail("Logout confirmation was not displayed")
            return
        }

        guard tap(page.confirmLogoutButton) else { return }

        XCTAssertTrue(
            page.loginEmailField.waitForExistence(timeout: 15),
            "Login screen was not displayed after logout"
        )
    }

    // MARK: - Complete Registration Flow

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