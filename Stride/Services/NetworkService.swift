import Foundation

@MainActor
final class NetworkService {
    private let baseURL = "https://strideapi-1048111785674.us-central1.run.app"

    var onSessionExpired: (() -> Void)?
    private var isRefreshing = false

    private var accessToken: String? {
        KeychainManager.shared.retrieve(key: "accessToken")
    }

    // MARK: - Token Refresh

    private struct RefreshTokenRequest: Codable { let refreshToken: String }
    private struct TokenData: Codable { let accessToken: String; let refreshToken: String }

    private func refreshAccessToken() async throws {
        guard let token = KeychainManager.shared.retrieve(key: "refreshToken") else {
            throw URLError(.userAuthenticationRequired)
        }
        guard let url = URL(string: baseURL + "/api/v1/auth/refresh") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(RefreshTokenRequest(refreshToken: token))

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, 200...299 ~= http.statusCode else {
            throw URLError(.userAuthenticationRequired)
        }
        let apiResponse = try JSONDecoder().decode(ApiResponse<TokenData>.self, from: data)
        guard let tokenData = apiResponse.data else { throw URLError(.userAuthenticationRequired) }
        KeychainManager.shared.save(token: tokenData.accessToken, key: "accessToken")
        KeychainManager.shared.save(token: tokenData.refreshToken, key: "refreshToken")
    }

    // MARK: - Core Request

    private func buildRequest(method: String, endpoint: String) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    private func execute(_ request: URLRequest, isRetry: Bool = false) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if http.statusCode == 401 && !isRetry && !isRefreshing {
            isRefreshing = true
            do {
                try await refreshAccessToken()
                isRefreshing = false
                var retried = request
                if let token = accessToken {
                    retried.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                return try await execute(retried, isRetry: true)
            } catch {
                isRefreshing = false
                onSessionExpired?()
                throw URLError(.userAuthenticationRequired)
            }
        }

        guard 200...299 ~= http.statusCode else { throw URLError(.badServerResponse) }
        return data
    }

    // MARK: - HTTP Methods

    func post<T: Codable, R: Codable>(_ endpoint: String, body: T) async throws -> R {
        guard var req = buildRequest(method: "POST", endpoint: endpoint) else { throw URLError(.badURL) }
        req.httpBody = try JSONEncoder().encode(body)
        return try JSONDecoder().decode(R.self, from: try await execute(req))
    }

    func get<R: Codable>(_ endpoint: String) async throws -> R {
        guard let req = buildRequest(method: "GET", endpoint: endpoint) else { throw URLError(.badURL) }
        return try JSONDecoder().decode(R.self, from: try await execute(req))
    }

    func put<T: Codable, R: Codable>(_ endpoint: String, body: T) async throws -> R {
        guard var req = buildRequest(method: "PUT", endpoint: endpoint) else { throw URLError(.badURL) }
        req.httpBody = try JSONEncoder().encode(body)
        return try JSONDecoder().decode(R.self, from: try await execute(req))
    }

    func patch<T: Codable, R: Codable>(_ endpoint: String, body: T) async throws -> R {
        guard var req = buildRequest(method: "PATCH", endpoint: endpoint) else { throw URLError(.badURL) }
        req.httpBody = try JSONEncoder().encode(body)
        return try JSONDecoder().decode(R.self, from: try await execute(req))
    }

    func delete<R: Codable>(_ endpoint: String) async throws -> R {
        guard let req = buildRequest(method: "DELETE", endpoint: endpoint) else { throw URLError(.badURL) }
        return try JSONDecoder().decode(R.self, from: try await execute(req))
    }

    // MARK: - Place Endpoints

    func getPlaces() async throws -> ApiResponse<[Place]> { try await get("/api/v1/places") }
    func createPlaceRequest(_ request: PlaceRequest) async throws -> ApiResponse<Place> { try await post("/api/v1/places", body: request) }
    func updatePlace(_ id: String, request: PlaceRequest) async throws -> ApiResponse<Place> { try await put("/api/v1/places/\(id)", body: request) }
    func deletePlace(_ id: String) async throws -> ApiResponse<String> { try await delete("/api/v1/places/\(id)") }
    func recordVisit(placeId: String) async throws -> ApiResponse<Place> { try await patch("/api/v1/places/\(placeId)/visit", body: [String: String]()) }

    // MARK: - Errand Endpoints

    func getErrands() async throws -> ApiResponse<[Errand]> { try await get("/api/v1/errands") }
    func createErrandRequest(_ request: ErrandRequest) async throws -> ApiResponse<Errand> { try await post("/api/v1/errands", body: request) }
    func updateErrand(_ id: String, request: ErrandRequest) async throws -> ApiResponse<Errand> { try await put("/api/v1/errands/\(id)", body: request) }
    func completeErrand(_ id: String) async throws -> ApiResponse<Errand> { try await patch("/api/v1/errands/\(id)/complete", body: [String: String]()) }
    func deleteErrand(_ id: String) async throws -> ApiResponse<String> { try await delete("/api/v1/errands/\(id)") }

    // MARK: - Auth Account Endpoints

    func updateProfile(request: UpdateProfileRequest) async throws -> ApiResponse<User> {
        try await put("/api/v1/auth/profile", body: request)
    }

    func changePassword(request: ChangePasswordRequest) async throws -> ApiResponse<String> {
        try await post("/api/v1/auth/change-password", body: request)
    }

    func deleteAccount() async throws -> ApiResponse<String> {
        try await delete("/api/v1/auth/account")
    }

    // MARK: - Smart Route

    func getErrandRoute(request: LocationRequest) async throws -> ApiResponse<[Errand]> {
        try await post("/api/v1/errands/route", body: request)
    }

    // MARK: - Nearby

    func getNearby(request: LocationRequest) async throws -> ApiResponse<NearbyData> {
        try await post("/api/v1/nearby", body: request)
    }

    // MARK: - Collection Endpoints

    func getCollections() async throws -> ApiResponse<[PlaceCollection]> {
        try await get("/api/v1/collections")
    }

    func createCollection(request: CollectionRequest) async throws -> ApiResponse<PlaceCollection> {
        try await post("/api/v1/collections", body: request)
    }

    func updateCollection(_ id: String, request: CollectionRequest) async throws -> ApiResponse<PlaceCollection> {
        try await put("/api/v1/collections/\(id)", body: request)
    }

    func deleteCollection(_ id: String) async throws -> ApiResponse<String> {
        try await delete("/api/v1/collections/\(id)")
    }
}
