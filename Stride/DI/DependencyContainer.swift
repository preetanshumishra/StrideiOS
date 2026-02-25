import Foundation

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    private lazy var networkService = NetworkService()

    nonisolated private init() {}

    // MARK: - Services

    func makeNetworkService() -> NetworkService {
        networkService
    }

    func makeAuthService() -> AuthService {
        AuthService(networkService: networkService)
    }

    func makePlaceService() -> PlaceService {
        PlaceService(networkService: networkService)
    }

    func makeErrandService() -> ErrandService {
        ErrandService(networkService: networkService)
    }

    // MARK: - ViewModels

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: makeAuthService())
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authService: makeAuthService())
    }

    func makeHomeViewModel(authService: AuthService) -> HomeViewModel {
        HomeViewModel(authService: authService)
    }

    func makePlacesViewModel() -> PlacesViewModel {
        PlacesViewModel(placeService: makePlaceService())
    }

    func makeErrandsViewModel() -> ErrandsViewModel {
        ErrandsViewModel(errandService: makeErrandService())
    }
}
