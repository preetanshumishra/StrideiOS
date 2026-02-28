import Foundation

@MainActor
final class PlaceService: ObservableObject {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getPlaces() async throws -> [Place] {
        let response: ApiResponse<[Place]> = try await networkService.get("/api/v1/places")
        return response.data ?? []
    }

    func createPlace(_ request: PlaceRequest) async throws -> Place {
        let response = try await networkService.createPlaceRequest(request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func updatePlace(_ id: String, _ request: PlaceRequest) async throws -> Place {
        let response = try await networkService.updatePlace(id, request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }

    func deletePlace(_ id: String) async throws {
        let _: ApiResponse<String> = try await networkService.deletePlace(id)
    }

    func recordVisit(_ id: String) async throws {
        let _: ApiResponse<Place> = try await networkService.recordVisit(placeId: id)
    }
}
