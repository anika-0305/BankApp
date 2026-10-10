
import XCTest

final class BankingFlowTests: BaseClass {

    // MARK: - Test 1: Invalid Email Format

    func testInvalidEmailFormat() {
        let steps = EasyBankSteps(app: app)

        steps.openLoginScreen()

        steps.login(
            email: "invalid-email",
            password: "TestPassword123!"
        )

        steps.verifyInvalidEmailError()
    }

    // MARK: - Test 2: Invalid Login Credentials

    func testInvalidLoginCredentials() {
        let steps = EasyBankSteps(app: app)

        let email = "unknown-\(UUID().uuidString)@example.com"

        steps.openLoginScreen()

        steps.login(
            email: email,
            password: "TestPassword123!"
        )

        steps.verifyInvalidCredentialsError()
    }

    // MARK: - Test 3: Register, Logout and Login

    func testRegisterLogoutAndLogin() {
        let steps = EasyBankSteps(app: app)

        let email = "test-\(UUID().uuidString)@example.com"
        let password = "TestPassword123!"

        steps.registerLogoutAndLogin(
            email: email,
            password: password
        )
    }
}
