import Foundation

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    private lazy var networkService = NetworkService()
    private lazy var locationManager = LocationManager()
    private lazy var routeService = RouteService(networkService: networkService)
    private lazy var nearbyService = NearbyService(networkService: networkService)
    lazy var collectionService: CollectionService = CollectionService(networkService: networkService)
    lazy var woosmapManager: WoosmapManager = WoosmapManager(
        placeService: makePlaceService(),
        nearbyService: nearbyService,
        locationManager: locationManager
    )

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
        PlacesViewModel(placeService: makePlaceService(), collectionService: collectionService)
    }

    func makeErrandsViewModel() -> ErrandsViewModel {
        ErrandsViewModel(errandService: makeErrandService())
    }

    func makeAddEditPlaceViewModel(place: Place? = nil) -> AddEditPlaceViewModel {
        AddEditPlaceViewModel(placeService: makePlaceService(), collectionService: collectionService, place: place)
    }

    func makeAddEditErrandViewModel(errand: Errand? = nil) -> AddEditErrandViewModel {
        AddEditErrandViewModel(errandService: makeErrandService(), placeService: makePlaceService(), errand: errand)
    }

    func makeSettingsViewModel(authService: AuthService) -> SettingsViewModel {
        SettingsViewModel(authService: authService)
    }

    func makeCollectionsViewModel() -> CollectionsViewModel {
        CollectionsViewModel(collectionService: collectionService)
    }

    func makeRouteService() -> RouteService { routeService }
    func makeNearbyService() -> NearbyService { nearbyService }

    func makeSmartRouteViewModel() -> SmartRouteViewModel {
        SmartRouteViewModel(routeService: routeService, locationManager: locationManager)
    }

    func makeNearbyViewModel() -> NearbyViewModel {
        NearbyViewModel(nearbyService: nearbyService, locationManager: locationManager)
    }
}
