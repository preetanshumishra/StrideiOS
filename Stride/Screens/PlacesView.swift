import SwiftUI

struct PlacesView: View {
    @ObservedObject var viewModel: PlacesViewModel
    @State private var showAddPlace = false
    @State private var editingPlace: Place?

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.collections.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") { viewModel.collectionFilter = nil }
                            .font(.caption)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(viewModel.collectionFilter == nil ? Color.indigo : Color(.systemGray5))
                            .foregroundColor(viewModel.collectionFilter == nil ? .white : .primary)
                            .cornerRadius(12)
                        ForEach(viewModel.collections) { collection in
                            Button(collection.name) { viewModel.collectionFilter = collection.id }
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(viewModel.collectionFilter == collection.id ? Color.indigo : Color(.systemGray5))
                                .foregroundColor(viewModel.collectionFilter == collection.id ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            List {
                if viewModel.filteredPlaces.isEmpty && !viewModel.isLoading {
                    Text(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty ? "No places saved yet" : "No results")
                        .foregroundColor(.gray)
                }

                ForEach(viewModel.filteredPlaces) { place in
                    PlaceRow(place: place)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingPlace = place
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task { await viewModel.recordVisit(id: place.id) }
                            } label: {
                                Label("Visit", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                }
                .onDelete { offsets in
                    Task {
                        for index in offsets {
                            await viewModel.deletePlace(id: viewModel.filteredPlaces[index].id)
                        }
                    }
                }
            }
            .refreshable { await viewModel.loadPlaces() }
            .searchable(text: $viewModel.searchText, prompt: "Search places")
        }
        .navigationTitle("My Places")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddPlace = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showAddPlace, onDismiss: {
            Task { await viewModel.loadPlaces() }
        }) {
            AddEditPlaceView(viewModel: DependencyContainer.shared.makeAddEditPlaceViewModel())
        }
        .sheet(item: $editingPlace, onDismiss: {
            Task { await viewModel.loadPlaces() }
        }) { place in
            AddEditPlaceView(viewModel: DependencyContainer.shared.makeAddEditPlaceViewModel(place: place))
        }
        .task {
            await viewModel.loadPlaces()
        }
    }
}
