import SwiftUI

@main
struct StrideApp: App {
    @StateObject private var authService: AuthService
    private let container = DependencyContainer.shared

    init() {
        let authService = container.makeAuthService()
        _authService = StateObject(wrappedValue: authService)
        authService.checkPersistedAuth()
    }

    var body: some Scene {
        WindowGroup {
            if authService.isLoggedIn {
                HomeView(viewModel: container.makeHomeViewModel(authService: authService))
            } else {
                LoginView(viewModel: container.makeLoginViewModel())
            }
        }
    }
}
