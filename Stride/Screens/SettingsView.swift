import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Button("Save Profile") {
                        Task { await viewModel.saveProfile() }
                    }
                    .disabled(viewModel.isLoading)
                }

                Section("Change Password") {
                    SecureField("Current Password", text: $viewModel.currentPassword)
                    SecureField("New Password", text: $viewModel.newPassword)
                    SecureField("Confirm New Password", text: $viewModel.confirmPassword)
                    Button("Change Password") {
                        Task { await viewModel.changePassword() }
                    }
                    .disabled(viewModel.isLoading)
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.showDeleteConfirm = true
                    } label: {
                        Text("Delete Account")
                    }
                }

                if let msg = viewModel.successMessage {
                    Section {
                        Text(msg)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                if let err = viewModel.errorMessage {
                    Section {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .alert("Delete Account", isPresented: $viewModel.showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all data. This cannot be undone.")
            }
        }
    }
}
