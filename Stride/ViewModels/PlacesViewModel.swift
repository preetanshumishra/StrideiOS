import Foundation

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let placeService: PlaceService

    init(placeService: PlaceService) {
        self.placeService = placeService
    }

    func loadPlaces() async {
        isLoading = true
        defer { isLoading = false }

        do {
            places = try await placeService.getPlaces()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
