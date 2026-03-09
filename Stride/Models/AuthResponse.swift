import Foundation

struct AuthResponse: Codable {
    let userId: String
    let email: String
    let firstName: String
    let lastName: String
    let accessToken: String
    let refreshToken: String

    var user: User {
        User(id: userId, email: email, firstName: firstName, lastName: lastName)
    }
}
