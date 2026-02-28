import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var showDeleteConfirm = false

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        if let user = authService.user {
            firstName = user.firstName
            lastName = user.lastName
            email = user.email
        }
    }

    func saveProfile() async {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.updateProfile(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces)
            )
            successMessage = "Profile updated"
        } catch {
            errorMessage = "Failed to update profile"
        }
        isLoading = false
    }

    func changePassword() async {
        guard !currentPassword.isEmpty, !newPassword.isEmpty else {
            errorMessage = "All password fields are required"
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match"
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "New password must be at least 8 characters"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            successMessage = "Password changed"
        } catch {
            errorMessage = "Failed to change password"
        }
        isLoading = false
    }

    func deleteAccount() async {
        isLoading = true
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = "Failed to delete account"
            isLoading = false
        }
    }
}
