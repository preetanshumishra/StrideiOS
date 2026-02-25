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
}
