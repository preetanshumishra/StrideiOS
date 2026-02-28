import Foundation

struct PlaceRequest: Codable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String?
    let notes: String?
    let personalRating: Int?
    let source: String
    let tags: [String]?
    let collectionId: String?
}
