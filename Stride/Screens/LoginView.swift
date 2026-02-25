import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var showPassword = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Stride")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.green)

                    Text("Your personal map that works for you")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)

                VStack(spacing: 12) {
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
                        await viewModel.login()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)

                NavigationLink(destination: RegisterView(viewModel: DependencyContainer.shared.makeRegisterViewModel())) {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Sign up")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

#Preview {
    LoginView(viewModel: DependencyContainer.shared.makeLoginViewModel())
}
