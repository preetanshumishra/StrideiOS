import Foundation

@MainActor
final class CollectionService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getCollections() async throws -> [PlaceCollection] {
        let response: ApiResponse<[PlaceCollection]> = try await networkService.getCollections()
        return response.data ?? []
    }

    func createCollection(_ request: CollectionRequest) async throws -> PlaceCollection {
        let response: ApiResponse<PlaceCollection> = try await networkService.createCollection(request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func updateCollection(_ id: String, _ request: CollectionRequest) async throws -> PlaceCollection {
        let response: ApiResponse<PlaceCollection> = try await networkService.updateCollection(id, request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func deleteCollection(_ id: String) async throws {
        let _: ApiResponse<String> = try await networkService.deleteCollection(id)
    }
}
