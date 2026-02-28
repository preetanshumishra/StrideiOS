import SwiftUI

struct AddEditErrandView: View {
    @ObservedObject var viewModel: AddEditErrandViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Required") {
                    TextField("Title", text: $viewModel.title)
                }

                Section("Details") {
                    TextField("Category", text: $viewModel.category)

                    Picker("Priority", selection: $viewModel.priority) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(.segmented)

                    if viewModel.places.isEmpty {
                        TextField("Linked Place ID (optional)", text: $viewModel.linkedPlaceId)
                            .font(.callout)
                    } else {
                        Picker("Linked Place", selection: $viewModel.linkedPlaceId) {
                            Text("None").tag("")
                            ForEach(viewModel.places) { place in
                                Text(place.name).tag(place.id)
                            }
                        }
                    }
                }

                Section("Deadline") {
                    Toggle("Set deadline", isOn: $viewModel.hasDeadline)
                    if viewModel.hasDeadline {
                        DatePicker(
                            "Date",
                            selection: $viewModel.deadline,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Recurring") {
                    Toggle("Repeat this errand", isOn: $viewModel.isRecurring)
                    if viewModel.isRecurring {
                        Stepper("Every \(viewModel.recurringInterval) \(viewModel.recurringUnit)",
                                value: $viewModel.recurringInterval, in: 1...365)
                        Picker("Unit", selection: $viewModel.recurringUnit) {
                            Text("Days").tag("days")
                            Text("Weeks").tag("weeks")
                            Text("Months").tag("months")
                        }
                        .pickerStyle(.segmented)
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
            .navigationTitle(viewModel.isEditing ? "Edit Errand" : "Add Errand")
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
