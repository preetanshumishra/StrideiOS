import SwiftUI

struct AddEditCollectionView: View {
    @ObservedObject var viewModel: AddEditCollectionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $viewModel.name)
                TextField("Description (optional)", text: $viewModel.description)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundColor(.red)
                }
            }

            Section {
                Button(action: {
                    Task {
                        await viewModel.save()
                        if viewModel.didSave { dismiss() }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text(viewModel.isEditing ? "Save Changes" : "Add Collection")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Collection" : "New Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
