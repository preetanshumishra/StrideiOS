import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var showPassword = false
    @State private var showRegister = false

    var body: some View {
        VStack {
            Spacer()

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
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    HStack {
                        if showPassword {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }

                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
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
            }

            Spacer()

            Button(action: { showRegister = true }) {
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Text("Sign up")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showRegister) {
            RegisterView(viewModel: DependencyContainer.shared.makeRegisterViewModel())
        }
    }
}

#Preview {
    let vm = DependencyContainer.shared.makeLoginViewModel()
    vm.email = "alex@stride.app"
    vm.password = "password123"
    return LoginView(viewModel: vm)
}
