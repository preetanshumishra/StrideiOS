import Foundation

@MainActor
final class SmartRouteViewModel: ObservableObject {
    @Published var routedErrands: [Errand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let routeService: RouteService
    let locationManager: LocationManager

    init(routeService: RouteService, locationManager: LocationManager) {
        self.routeService = routeService
        self.locationManager = locationManager
    }

    func fetchRoute() {
        guard let location = locationManager.currentLocation else {
            locationManager.requestLocation()
            return
        }
        Task {
            isLoading = true
            errorMessage = nil
            do {
                routedErrands = try await routeService.getRoute(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            } catch {
                errorMessage = "Failed to load route"
            }
            isLoading = false
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}
