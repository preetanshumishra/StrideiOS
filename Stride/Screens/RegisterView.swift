import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showPassword = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Join Stride to manage your places and errands")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)

            VStack(spacing: 12) {
                TextField("First Name", text: $viewModel.firstName)
                    .textFieldStyle(.roundedBorder)

                TextField("Last Name", text: $viewModel.lastName)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                HStack {
                    if showPassword {
                        TextField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.green)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                Task {
                    await viewModel.register()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)

            Spacer()

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Text("Login")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView(viewModel: DependencyContainer.shared.makeRegisterViewModel())
}
