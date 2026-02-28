import Foundation

struct UpdateProfileRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
}
