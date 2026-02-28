import Foundation

@MainActor
final class NearbyViewModel: ObservableObject {
    @Published var nearbyPlaces: [Place] = []
    @Published var linkedErrands: [Errand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    var radiusKm: Double = 1.0

    private let nearbyService: NearbyService
    let locationManager: LocationManager

    init(nearbyService: NearbyService, locationManager: LocationManager) {
        self.nearbyService = nearbyService
        self.locationManager = locationManager
    }

    func fetchNearby() {
        guard let location = locationManager.currentLocation else {
            locationManager.requestLocation()
            return
        }
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let result = try await nearbyService.getNearby(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    radiusKm: radiusKm
                )
                nearbyPlaces = result.nearbyPlaces
                linkedErrands = result.linkedErrands
            } catch {
                errorMessage = "Failed to load nearby"
            }
            isLoading = false
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}
