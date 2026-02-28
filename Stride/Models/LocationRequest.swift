import Foundation

struct LocationRequest: Codable {
    let latitude: Double
    let longitude: Double
    let radiusKm: Double?
}
