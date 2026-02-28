import CoreLocation

private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var onLocation: ((CLLocation) -> Void)?
    var onError: ((Error) -> Void)?
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocation?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }
}

@MainActor
final class LocationManager: ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    private let manager = CLLocationManager()
    private let delegate = LocationDelegate()

    init() {
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus

        delegate.onLocation = { [weak self] location in
            Task { @MainActor [weak self] in
                self?.currentLocation = location
                self?.locationError = nil
            }
        }

        delegate.onError = { [weak self] error in
            Task { @MainActor [weak self] in
                self?.locationError = error.localizedDescription
            }
        }

        delegate.onAuthorizationChange = { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.manager.requestLocation()
                }
            }
        }
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            locationError = "Location access denied. Please enable in Settings."
        }
    }
}
