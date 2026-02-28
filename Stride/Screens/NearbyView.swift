import SwiftUI

struct NearbyView: View {
    @ObservedObject var viewModel: NearbyViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Looking for nearby places...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Try Again") { viewModel.fetchNearby() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.nearbyPlaces.isEmpty && viewModel.linkedErrands.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "location.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No places nearby")
                        .foregroundColor(.gray)
                    Button("Search Nearby") { viewModel.fetchNearby() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !viewModel.nearbyPlaces.isEmpty {
                        Section("Nearby Places") {
                            ForEach(viewModel.nearbyPlaces) { place in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(place.name).fontWeight(.medium)
                                        Text(place.address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if let dist = place.distanceKm {
                                        Text(String(format: "%.2f km", dist))
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    if !viewModel.linkedErrands.isEmpty {
                        Section("Errands Here") {
                            ForEach(viewModel.linkedErrands) { errand in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(errand.title).fontWeight(.medium)
                                    Text(errand.priority.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Nearby")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { viewModel.fetchNearby() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { viewModel.fetchNearby() }
    }
}
