import Foundation

@MainActor
final class AddEditPlaceViewModel: ObservableObject {
    @Published var name = ""
    @Published var address = ""
    @Published var latitudeText = ""
    @Published var longitudeText = ""
    @Published var category = ""
    @Published var notes = ""
    @Published var personalRating = 0
    @Published var tagsText = ""
    @Published var collectionId: String? = nil
    @Published var collections: [PlaceCollection] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let existingPlace: Place?
    private let placeService: PlaceService
    private let collectionService: CollectionService

    var isEditing: Bool { existingPlace != nil }

    init(placeService: PlaceService, collectionService: CollectionService, place: Place? = nil) {
        self.placeService = placeService
        self.collectionService = collectionService
        self.existingPlace = place
        if let place = place {
            name = place.name
            address = place.address
            latitudeText = String(place.latitude)
            longitudeText = String(place.longitude)
            category = place.category
            notes = place.notes
            personalRating = place.rating ?? 0
            tagsText = place.tags.joined(separator: ", ")
            collectionId = place.collectionId
        }
        Task { await loadCollections() }
    }

    private func loadCollections() async {
        do {
            collections = try await collectionService.getCollections()
        } catch {
            // Non-critical — silently ignore
        }
    }

    func save() async {
        guard validate() else { return }

        guard let latitude = Double(latitudeText), let longitude = Double(longitudeText) else {
            errorMessage = "Latitude and longitude must be valid numbers"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let request = PlaceRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            latitude: latitude,
            longitude: longitude,
            category: category.trimmingCharacters(in: .whitespaces).isEmpty ? nil : category.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
            personalRating: personalRating == 0 ? nil : personalRating,
            source: existingPlace?.source ?? "manual",
            tags: tags.isEmpty ? nil : tags,
            collectionId: collectionId?.isEmpty == true ? nil : collectionId
        )

        do {
            if let existing = existingPlace {
                _ = try await placeService.updatePlace(existing.id, request)
            } else {
                _ = try await placeService.createPlace(request)
            }
            errorMessage = nil
            didSave = true
        } catch {
            errorMessage = "Failed to save place. Please try again."
        }
    }

    private func validate() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Name is required"
            return false
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Address is required"
            return false
        }
        if latitudeText.trimmingCharacters(in: .whitespaces).isEmpty ||
           longitudeText.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Latitude and longitude are required"
            return false
        }
        return true
    }
}
