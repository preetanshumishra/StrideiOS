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
}
