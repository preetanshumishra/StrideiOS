import Foundation

struct RecurringRequest: Codable {
    let interval: Int
    let unit: String
}

struct ErrandRequest: Codable {
    let title: String
    let category: String?
    let priority: String
    let deadline: String?
    let linkedPlaceId: String?
    let recurring: RecurringRequest?
}
