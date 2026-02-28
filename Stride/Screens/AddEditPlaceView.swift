import SwiftUI

struct AddEditPlaceView: View {
    @ObservedObject var viewModel: AddEditPlaceViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Required") {
                    TextField("Name", text: $viewModel.name)

                    TextField("Address", text: $viewModel.address)

                    TextField("Latitude", text: $viewModel.latitudeText)
                        .keyboardType(.decimalPad)

                    TextField("Longitude", text: $viewModel.longitudeText)
                        .keyboardType(.decimalPad)
                }

                Section("Optional") {
                    TextField("Category", text: $viewModel.category)

                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)

                    Picker("Rating", selection: $viewModel.personalRating) {
                        Text("No rating").tag(0)
                        ForEach(1...5, id: \.self) { i in
                            Text("\(i) / 5").tag(i)
                        }
                    }

                    TextField("Tags (comma-separated)", text: $viewModel.tagsText)
                        .font(.callout)

                    if !viewModel.collections.isEmpty {
                        Picker("Collection", selection: $viewModel.collectionId) {
                            Text("None").tag(String?.none)
                            ForEach(viewModel.collections) { collection in
                                Text(collection.name).tag(Optional(collection.id))
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Place" : "Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .onChange(of: viewModel.didSave) { saved in
                if saved { presentationMode.wrappedValue.dismiss() }
            }
        }
    }
}
