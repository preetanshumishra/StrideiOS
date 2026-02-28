import Foundation

@MainActor
final class RouteService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getRoute(latitude: Double, longitude: Double) async throws -> [Errand] {
        let request = LocationRequest(latitude: latitude, longitude: longitude, radiusKm: nil)
        let response: ApiResponse<[Errand]> = try await networkService.getErrandRoute(request: request)
        guard let data = response.data else { throw URLError(.cannotParseResponse) }
        return data
    }
}
