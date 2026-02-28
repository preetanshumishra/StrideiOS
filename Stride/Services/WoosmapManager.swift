import Foundation
import CoreLocation
import UserNotifications
import WoosmapGeofencing

@MainActor
final class WoosmapManager {

    private let placeService: PlaceService
    private let nearbyService: NearbyService
    private let locationManager: LocationManager

    private var savedPlaces: [Place] = []

    private lazy var visitDelegate: VisitDelegate = {
        let d = VisitDelegate()
        d.onVisit = { [weak self] lat, lng in
            Task { @MainActor [weak self] in
                self?.handleVisit(latitude: lat, longitude: lng)
            }
        }
        return d
    }()

    private lazy var regionDelegate: RegionDelegate = {
        let d = RegionDelegate()
        d.onEnter = { [weak self] identifier in
            Task { @MainActor [weak self] in
                self?.handleGeofenceEnter(identifier: identifier)
            }
        }
        return d
    }()

    init(placeService: PlaceService, nearbyService: NearbyService, locationManager: LocationManager) {
        self.placeService = placeService
        self.nearbyService = nearbyService
        self.locationManager = locationManager
    }

    func startTracking() {
        WoosmapGeofenceManager.shared.setWoosmapAPIKey(key: "")
        WoosmapGeofenceManager.shared.locationService.visitDelegate = visitDelegate
        WoosmapGeofenceManager.shared.locationService.regionDelegate = regionDelegate
        WoosmapGeofenceManager.shared.startTracking(configurationProfile: .visitsTracking)
    }

    func stopTracking() {
        WoosmapGeofenceManager.shared.stopTracking()
    }

    func registerGeofences(places: [Place]) {
        savedPlaces = places
        let toRegister = Array(places.prefix(7))
        for place in toRegister {
            let center = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            _ = WoosmapGeofenceManager.shared.locationService.addRegion(
                identifier: "place_\(place.id)",
                center: center,
                radius: 100,
                type: "circle"
            )
        }
    }

    private func handleVisit(latitude: Double, longitude: Double) {
        guard let nearest = findNearestPlace(latitude: latitude, longitude: longitude, thresholdKm: 0.1) else { return }
        Task {
            try? await placeService.recordVisit(nearest.id)
        }
    }

    private func handleGeofenceEnter(identifier: String) {
        guard identifier.hasPrefix("place_") else { return }
        let placeId = String(identifier.dropFirst("place_".count))
        guard let place = savedPlaces.first(where: { $0.id == placeId }) else { return }
        guard let location = locationManager.currentLocation else {
            showNotification(placeName: place.name, errandCount: 0)
            return
        }
        Task {
            do {
                let nearby = try await nearbyService.getNearby(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                showNotification(placeName: place.name, errandCount: nearby.linkedErrands.count)
            } catch {
                showNotification(placeName: place.name, errandCount: 0)
            }
        }
    }

    private func findNearestPlace(latitude: Double, longitude: Double, thresholdKm: Double) -> Place? {
        var nearest: Place?
        var minDistance = Double.greatestFiniteMagnitude
        for place in savedPlaces {
            let dist = haversineKm(lat1: latitude, lng1: longitude, lat2: place.latitude, lng2: place.longitude)
            if dist < thresholdKm && dist < minDistance {
                minDistance = dist
                nearest = place
            }
        }
        return nearest
    }

    private func haversineKm(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let R = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLng = (lng2 - lng1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180)
            * sin(dLng / 2) * sin(dLng / 2)
        return R * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    private func showNotification(placeName: String, errandCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Near \(placeName)"
        content.body = errandCount > 0
            ? "You have \(errandCount) pending errand\(errandCount == 1 ? "" : "s") here"
            : "You're near one of your saved places"
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Delegate Helpers

private final class VisitDelegate: NSObject, VisitServiceDelegate, @unchecked Sendable {
    var onVisit: ((Double, Double) -> Void)?

    func processVisit(visit: Visit) {
        onVisit?(visit.latitude, visit.longitude)
    }
}

private final class RegionDelegate: NSObject, RegionsServiceDelegate, @unchecked Sendable {
    var onEnter: ((String) -> Void)?

    func didEnterPOIRegion(POIregion: Region) {
        onEnter?(POIregion.identifier)
    }

    func didExitPOIRegion(POIregion: Region) {}

    func updateRegions(regions: Set<CLRegion>) {}

    func workZOIEnter(classifiedRegion: Region) {}
    
    func homeZOIEnter(classifiedRegion: Region) {}
}
