import Foundation

struct ApiResponse<T: Codable>: Codable {
    let status: String
    let message: String?
    let data: T?
}
