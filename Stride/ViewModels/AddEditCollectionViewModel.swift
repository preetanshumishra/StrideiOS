import Foundation

@MainActor
final class AddEditCollectionViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let existingCollection: PlaceCollection?
    private let collectionService: CollectionService

    var isEditing: Bool { existingCollection != nil }

    init(collectionService: CollectionService, collection: PlaceCollection? = nil) {
        self.collectionService = collectionService
        self.existingCollection = collection
        if let c = collection {
            name = c.name
            description = c.description ?? ""
        }
    }

    func save() async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name is required"
            return
        }
        isLoading = true
        defer { isLoading = false }
        let request = CollectionRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description.trimmingCharacters(in: .whitespaces)
        )
        do {
            if let existing = existingCollection {
                _ = try await collectionService.updateCollection(existing.id, request)
            } else {
                _ = try await collectionService.createCollection(request)
            }
            errorMessage = nil
            didSave = true
        } catch {
            errorMessage = "Failed to save collection."
        }
    }
}
