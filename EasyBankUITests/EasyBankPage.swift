
import XCTest

final class EasyBankPage {

    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Onboarding

    var onboardingLoginButton: XCUIElement {
        app.buttons["onboarding.login"]
    }

    var onboardingRegisterButton: XCUIElement {
        app.buttons["onboarding.register"]
    }

    // MARK: - Login

    var loginEmailField: XCUIElement {
        app.textFields["login.email"]
    }

    var loginPasswordField: XCUIElement {
        app.secureTextFields["login.password"]
    }

    var loginPasswordVisibilityButton: XCUIElement {
        loginPasswordField.buttons["hide"]
    }

    var visibleLoginPasswordField: XCUIElement {
        app.textFields["login.password"]
    }

    var loginSubmitButton: XCUIElement {
        app.buttons["login.submit"]
    }

    var loginErrorMessage: XCUIElement {
        app.staticTexts["login.error"]
    }

    // MARK: - Registration

    var registrationEmailField: XCUIElement {
        app.textFields["registration.email"]
    }

    var registrationPasswordField: XCUIElement {
        app.secureTextFields["registration.password"]
    }

    var registrationPasswordVisibilityButton: XCUIElement {
        registrationPasswordField.buttons["hide"]
    }

    var visibleRegistrationPasswordField: XCUIElement {
        app.textFields["registration.password"]
    }

    var registrationRepeatPasswordField: XCUIElement {
        app.secureTextFields["registration.repeatPassword"]
    }

    var repeatPasswordVisibilityButton: XCUIElement {
        registrationRepeatPasswordField.buttons["hide"]
    }

    var visibleRepeatPasswordField: XCUIElement {
        app.textFields["registration.repeatPassword"]
    }

    var registrationSubmitButton: XCUIElement {
        app.buttons["registration.submit"]
    }

    var registrationErrorMessage: XCUIElement {
        app.staticTexts["registration.error"]
    }

    // MARK: - Home

    var homeTab: XCUIElement {
        app.tabBars.buttons["Home"]
    }

    var sendMoneyButton: XCUIElement {
        app.buttons["home.sendMoney"]
    }

    var logoutButton: XCUIElement {
        app.buttons["home.logout"]
    }

    // MARK: - Logout Confirmation

    var logoutAlert: XCUIElement {
        app.alerts["Logging Out"]
    }

    var confirmLogoutButton: XCUIElement {
        logoutAlert.buttons["Yes"]
    }

    var cancelLogoutButton: XCUIElement {
        logoutAlert.buttons["No"]
    }
}
