import Foundation

@MainActor
final class ErrandService: ObservableObject {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getErrands() async throws -> [Errand] {
        let response: ApiResponse<[Errand]> = try await networkService.get("/api/v1/errands")
        return response.data ?? []
    }

    func createErrand(_ request: ErrandRequest) async throws -> Errand {
        let response = try await networkService.createErrandRequest(request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func updateErrand(_ id: String, _ request: ErrandRequest) async throws -> Errand {
        let response = try await networkService.updateErrand(id, request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func completeErrand(_ id: String) async throws -> Errand {
        let response = try await networkService.completeErrand(id)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func deleteErrand(_ id: String) async throws {
        let _: ApiResponse<String> = try await networkService.deleteErrand(id)
    }
}
