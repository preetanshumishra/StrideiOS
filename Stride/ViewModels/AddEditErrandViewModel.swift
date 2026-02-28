import Foundation

@MainActor
final class AddEditErrandViewModel: ObservableObject {
    @Published var title = ""
    @Published var category = ""
    @Published var priority = "medium"
    @Published var linkedPlaceId = ""
    @Published var hasDeadline = false
    @Published var deadline = Date()
    @Published var isRecurring = false
    @Published var recurringInterval = 7
    @Published var recurringUnit = "days"
    @Published var places: [Place] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSave = false

    let existingErrand: Errand?
    private let errandService: ErrandService
    private let placeService: PlaceService

    var isEditing: Bool { existingErrand != nil }

    init(errandService: ErrandService, placeService: PlaceService, errand: Errand? = nil) {
        self.errandService = errandService
        self.placeService = placeService
        self.existingErrand = errand
        if let errand = errand {
            title = errand.title
            category = errand.category
            priority = errand.priority
            linkedPlaceId = errand.linkedPlaceId ?? ""
            if let deadlineStr = errand.deadline {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: deadlineStr) {
                    hasDeadline = true
                    deadline = date
                }
            }
            if let rec = errand.recurring {
                isRecurring = true
                recurringInterval = rec.interval
                recurringUnit = rec.unit
            }
        }
        Task { await loadPlaces() }
    }

    private func loadPlaces() async {
        do {
            places = try await placeService.getPlaces()
        } catch {
            // Non-critical — silently ignore
        }
    }

    func save() async {
        guard validate() else { return }

        isLoading = true
        defer { isLoading = false }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let recurring = isRecurring ? RecurringRequest(interval: recurringInterval, unit: recurringUnit) : nil
        let request = ErrandRequest(
            title: title.trimmingCharacters(in: .whitespaces),
            category: category.trimmingCharacters(in: .whitespaces).isEmpty ? nil : category.trimmingCharacters(in: .whitespaces),
            priority: priority,
            deadline: hasDeadline ? formatter.string(from: deadline) : nil,
            linkedPlaceId: linkedPlaceId.trimmingCharacters(in: .whitespaces).isEmpty ? nil : linkedPlaceId.trimmingCharacters(in: .whitespaces),
            recurring: recurring
        )

        do {
            if let existing = existingErrand {
                _ = try await errandService.updateErrand(existing.id, request)
            } else {
                _ = try await errandService.createErrand(request)
            }
            errorMessage = nil
            didSave = true
        } catch {
            errorMessage = "Failed to save errand. Please try again."
        }
    }

    private func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Title is required"
            return false
        }
        return true
    }
}
