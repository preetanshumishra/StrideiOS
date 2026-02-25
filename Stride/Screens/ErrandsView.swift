import SwiftUI

struct ErrandsView: View {
    @ObservedObject var viewModel: ErrandsViewModel

    var body: some View {
        List {
            if viewModel.errands.isEmpty && !viewModel.isLoading {
                Text("No errands yet")
                    .foregroundColor(.gray)
            }

            ForEach(viewModel.errands) { errand in
                ErrandRow(errand: errand)
            }
        }
        .navigationTitle("Errands")
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadErrands()
        }
    }
}
