import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func login() async {
        guard validateInputs() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authService.login(email: email, password: password)
            authService.setAuthenticatedUser(response.user, accessToken: response.accessToken, refreshToken: response.refreshToken)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validateInputs() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Email is required"
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return false
        }

        return true
    }
}
