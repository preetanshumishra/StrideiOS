import Foundation

struct NearbyData: Codable {
    let nearbyPlaces: [Place]
    let linkedErrands: [Errand]
    let radiusKm: Double
}
