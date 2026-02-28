import Foundation

struct PlaceCollection: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let icon: String
    let shared: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, name, description, icon, shared
        case createdAt, updatedAt
    }
}
