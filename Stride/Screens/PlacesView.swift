import SwiftUI

struct PlacesView: View {
    @ObservedObject var viewModel: PlacesViewModel

    var body: some View {
        List {
            if viewModel.places.isEmpty && !viewModel.isLoading {
                Text("No places saved yet")
                    .foregroundColor(.gray)
            }

            ForEach(viewModel.places) { place in
                PlaceRow(place: place)
            }
        }
        .navigationTitle("My Places")
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadPlaces()
        }
    }
}
