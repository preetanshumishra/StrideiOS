import Foundation

@MainActor
final class ErrandsViewModel: ObservableObject {
    @Published var errands: [Errand] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

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
}
