import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    var userName: String {
        authService.user?.firstName ?? "User"
    }

    var userEmail: String {
        authService.user?.email ?? ""
    }

    func logout() async {
        await authService.logout()
    }
}
