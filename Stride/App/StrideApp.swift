import SwiftUI
import UserNotifications

@main
struct StrideApp: App {
    @StateObject private var authService: AuthService
    private let container = DependencyContainer.shared

    init() {
        let authService = container.makeAuthService()
        _authService = StateObject(wrappedValue: authService)
        container.makeNetworkService().onSessionExpired = {
            authService.clearAuthentication()
        }
        authService.checkPersistedAuth()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isLoggedIn {
                    HomeView(viewModel: container.makeHomeViewModel(authService: authService))
                } else {
                    LoginView(viewModel: container.makeLoginViewModel())
                }
            }
            .task {
                _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                if authService.isLoggedIn {
                    container.woosmapManager.startTracking()
                }
            }
            .onChange(of: authService.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    container.woosmapManager.startTracking()
                } else {
                    container.woosmapManager.stopTracking()
                }
            }
        }
    }
}
