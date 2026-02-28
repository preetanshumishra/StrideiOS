import SwiftUI

struct CollectionsView: View {
    @ObservedObject var viewModel: CollectionsViewModel
    let collectionService: CollectionService
    @State private var showAddSheet = false
    @State private var editingCollection: PlaceCollection? = nil

    var body: some View {
        List {
            ForEach(viewModel.collections) { collection in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.name)
                            .font(.headline)
                        if let desc = collection.description, !desc.isEmpty {
                            Text(desc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { editingCollection = collection }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteCollection(id: collection.id) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .refreshable { await viewModel.loadCollections() }
        .navigationTitle("Collections")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            Task { await viewModel.loadCollections() }
        }) {
            NavigationView {
                AddEditCollectionView(
                    viewModel: AddEditCollectionViewModel(collectionService: collectionService)
                )
            }
        }
        .sheet(item: $editingCollection, onDismiss: {
            Task { await viewModel.loadCollections() }
        }) { collection in
            NavigationView {
                AddEditCollectionView(
                    viewModel: AddEditCollectionViewModel(collectionService: collectionService, collection: collection)
                )
            }
        }
        .task { await viewModel.loadCollections() }
    }
}
