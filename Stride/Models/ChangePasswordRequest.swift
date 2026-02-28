import Foundation

struct ChangePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
}
