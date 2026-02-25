import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: User?

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let apiResponse: ApiResponse<AuthResponse> = try await networkService.post("/api/v1/auth/login", body: request)
        guard let data = apiResponse.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func register(email: String, password: String, firstName: String, lastName: String) async throws -> AuthResponse {
        let request = RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        let apiResponse: ApiResponse<AuthResponse> = try await networkService.post("/api/v1/auth/register", body: request)
        guard let data = apiResponse.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func getProfile() async throws -> User {
        return try await networkService.get("/api/v1/auth/profile")
    }

    func setAuthenticatedUser(_ user: User, accessToken: String, refreshToken: String) {
        self.user = user
        self.isLoggedIn = true
        KeychainManager.shared.save(token: accessToken, key: "accessToken")
        KeychainManager.shared.save(token: refreshToken, key: "refreshToken")
    }

    func clearAuthentication() {
        self.user = nil
        self.isLoggedIn = false
        KeychainManager.shared.delete(key: "accessToken")
        KeychainManager.shared.delete(key: "refreshToken")
    }

    func logout() async {
        if let token = KeychainManager.shared.retrieve(key: "refreshToken") {
            let _: ApiResponse<String>? = try? await networkService.post(
                "/api/v1/auth/logout",
                body: ["refreshToken": token] as [String: String]
            )
        }
        clearAuthentication()
    }

    func checkPersistedAuth() {
        if KeychainManager.shared.retrieve(key: "accessToken") != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}
