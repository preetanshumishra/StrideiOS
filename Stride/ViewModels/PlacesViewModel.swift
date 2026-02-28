import Foundation

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var collectionFilter: String? = nil
    @Published var collections: [PlaceCollection] = []

    var filteredPlaces: [Place] {
        var result = places
        if let colId = collectionFilter {
            result = result.filter { $0.collectionId == colId }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.address.lowercased().contains(query) ||
                $0.category.lowercased().contains(query)
            }
        }
        return result
    }

    private let placeService: PlaceService
    private let collectionService: CollectionService

    init(placeService: PlaceService, collectionService: CollectionService) {
        self.placeService = placeService
        self.collectionService = collectionService
        Task { await loadCollections() }
    }

    private func loadCollections() async {
        do {
            collections = try await collectionService.getCollections()
        } catch {
            // silently ignore collection load errors
        }
    }

    func loadPlaces() async {
        isLoading = true
        defer { isLoading = false }

        do {
            places = try await placeService.getPlaces()
            errorMessage = nil
            DependencyContainer.shared.woosmapManager.registerGeofences(places: places)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePlace(id: String) async {
        do {
            try await placeService.deletePlace(id)
            places.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete place"
        }
    }

    func recordVisit(id: String) async {
        do {
            try await placeService.recordVisit(id)
            await loadPlaces()
        } catch {
            errorMessage = "Failed to record visit."
        }
    }
}
