import Foundation

struct Place: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String
    let tags: [String]
    let notes: String
    let rating: Int?
    let collectionId: String?
    let visitCount: Int
    let lastVisited: String?
    let source: String
    let createdAt: String
    let updatedAt: String
    let distanceKm: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, name, address, latitude, longitude
        case category, tags, notes, rating, collectionId
        case visitCount, lastVisited, source
        case createdAt, updatedAt
        case distanceKm
    }
}
