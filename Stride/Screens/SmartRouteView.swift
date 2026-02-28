import SwiftUI

struct SmartRouteView: View {
    @ObservedObject var viewModel: SmartRouteViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Finding optimal route...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Try Again") { viewModel.fetchRoute() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.routedErrands.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "map.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No pending errands to route")
                        .foregroundColor(.gray)
                    Button("Get Route") { viewModel.fetchRoute() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(viewModel.routedErrands.enumerated()), id: \.element.id) { index, errand in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(errand.title).fontWeight(.medium)
                            Text(errand.priority.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if let dist = errand.distanceKm {
                            Text(String(format: "%.1f km", dist))
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .navigationTitle("Smart Route")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { viewModel.fetchRoute() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { viewModel.fetchRoute() }
    }
}
