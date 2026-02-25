import Foundation

@MainActor
final class NetworkService {
    private let baseURL = "http://localhost:5001"
    private var accessToken: String? {
        KeychainManager.shared.retrieve(key: "accessToken")
    }

    func post<T: Codable, R: Codable>(
        _ endpoint: String,
        body: T
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(R.self, from: data)
    }

    func get<R: Codable>(_ endpoint: String) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(R.self, from: data)
    }

    func put<T: Codable, R: Codable>(
        _ endpoint: String,
        body: T
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(R.self, from: data)
    }

    func delete<R: Codable>(_ endpoint: String) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(R.self, from: data)
    }

    // MARK: - Place Endpoints

    func getPlaces() async throws -> ApiResponse<[Place]> {
        try await get("/api/v1/places")
    }

    func createPlace(_ place: Place) async throws -> ApiResponse<Place> {
        try await post("/api/v1/places", body: place)
    }

    func deletePlace(_ id: String) async throws -> ApiResponse<[String: String]> {
        try await delete("/api/v1/places/\(id)")
    }

    // MARK: - Errand Endpoints

    func getErrands() async throws -> ApiResponse<[Errand]> {
        try await get("/api/v1/errands")
    }

    func createErrand(_ errand: Errand) async throws -> ApiResponse<Errand> {
        try await post("/api/v1/errands", body: errand)
    }

    func deleteErrand(_ id: String) async throws -> ApiResponse<[String: String]> {
        try await delete("/api/v1/errands/\(id)")
    }
}
