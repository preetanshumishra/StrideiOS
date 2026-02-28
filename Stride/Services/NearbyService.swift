import Foundation

@MainActor
final class NearbyService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getNearby(latitude: Double, longitude: Double, radiusKm: Double = 1.0) async throws -> NearbyData {
        let request = LocationRequest(latitude: latitude, longitude: longitude, radiusKm: radiusKm)
        let response: ApiResponse<NearbyData> = try await networkService.getNearby(request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }
}
