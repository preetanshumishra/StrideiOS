import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome, \(viewModel.userName)!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(viewModel.userEmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                NavigationLink(destination: PlacesView(viewModel: DependencyContainer.shared.makePlacesViewModel())) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.green)
                        Text("My Places")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: ErrandsView(viewModel: DependencyContainer.shared.makeErrandsViewModel())) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundColor(.orange)
                        Text("Errands")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    Task {
                        await viewModel.logout()
                    }
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Stride")
        }
    }
}
