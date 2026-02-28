import Foundation

struct Errand: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let category: String
    let linkedPlaceId: String?
    let priority: String
    let deadline: String?
    let recurring: Recurring?
    let status: String
    let completedAt: String?
    let createdAt: String
    let updatedAt: String
    let distanceKm: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, title, category, linkedPlaceId
        case priority, deadline, recurring, status
        case completedAt, createdAt, updatedAt
        case distanceKm
    }
}

struct Recurring: Codable {
    let interval: Int
    let unit: String
}
