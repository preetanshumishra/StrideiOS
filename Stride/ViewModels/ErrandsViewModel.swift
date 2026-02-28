import Foundation

@MainActor
final class ErrandsViewModel: ObservableObject {
    @Published var errands: [Errand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var statusFilter = "all"
    @Published var priorityFilter = "all"

    var filteredErrands: [Errand] {
        errands.filter { errand in
            let statusMatch = statusFilter == "all" || errand.status == statusFilter
            let priorityMatch = priorityFilter == "all" || errand.priority == priorityFilter
            return statusMatch && priorityMatch
        }
    }

    private let errandService: ErrandService

    init(errandService: ErrandService) {
        self.errandService = errandService
    }

    func loadErrands() async {
        isLoading = true
        defer { isLoading = false }

        do {
            errands = try await errandService.getErrands()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeErrand(id: String) async {
        do {
            let updated = try await errandService.completeErrand(id)
            if let idx = errands.firstIndex(where: { $0.id == id }) {
                errands[idx] = updated
            }
        } catch {
            errorMessage = "Failed to complete errand"
        }
    }

    func deleteErrand(id: String) async {
        do {
            try await errandService.deleteErrand(id)
            errands.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete errand"
        }
    }
}
