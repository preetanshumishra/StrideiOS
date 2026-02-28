import Foundation

@MainActor
final class CollectionsViewModel: ObservableObject {
    @Published var collections: [PlaceCollection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let collectionService: CollectionService

    init(collectionService: CollectionService) {
        self.collectionService = collectionService
    }

    func loadCollections() async {
        isLoading = true
        errorMessage = nil
        do {
            collections = try await collectionService.getCollections()
        } catch {
            errorMessage = "Failed to load collections."
        }
        isLoading = false
    }

    func deleteCollection(id: String) async {
        do {
            try await collectionService.deleteCollection(id)
            collections.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete collection."
        }
    }
}
