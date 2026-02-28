import SwiftUI

struct ErrandsView: View {
    @ObservedObject var viewModel: ErrandsViewModel
    @State private var showAddErrand = false
    @State private var editingErrand: Errand?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("Status:").font(.caption).foregroundColor(.secondary)
                    ForEach(["all", "pending", "done"], id: \.self) { status in
                        Button(status == "all" ? "All" : status.capitalized) {
                            viewModel.statusFilter = status
                        }
                        .font(.caption)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(viewModel.statusFilter == status ? Color.blue : Color(.systemGray5))
                        .foregroundColor(viewModel.statusFilter == status ? .white : .primary)
                        .cornerRadius(12)
                    }
                    Divider().frame(height: 20)
                    Text("Priority:").font(.caption).foregroundColor(.secondary)
                    ForEach(["all", "low", "medium", "high"], id: \.self) { p in
                        Button(p == "all" ? "All" : p.capitalized) {
                            viewModel.priorityFilter = p
                        }
                        .font(.caption)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(viewModel.priorityFilter == p ? Color.orange : Color(.systemGray5))
                        .foregroundColor(viewModel.priorityFilter == p ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            List {
                if viewModel.filteredErrands.isEmpty && !viewModel.isLoading {
                    Text("No errands yet")
                        .foregroundColor(.gray)
                }

                ForEach(viewModel.filteredErrands) { errand in
                    ErrandRow(errand: errand, onComplete: errand.status == "pending" ? {
                        Task { await viewModel.completeErrand(id: errand.id) }
                    } : nil)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingErrand = errand
                    }
                }
                .onDelete { offsets in
                    Task {
                        for index in offsets {
                            await viewModel.deleteErrand(id: viewModel.filteredErrands[index].id)
                        }
                    }
                }
            }
            .refreshable { await viewModel.loadErrands() }
        }
        .navigationTitle("Errands")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddErrand = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showAddErrand, onDismiss: {
            Task { await viewModel.loadErrands() }
        }) {
            AddEditErrandView(viewModel: DependencyContainer.shared.makeAddEditErrandViewModel())
        }
        .sheet(item: $editingErrand, onDismiss: {
            Task { await viewModel.loadErrands() }
        }) { errand in
            AddEditErrandView(viewModel: DependencyContainer.shared.makeAddEditErrandViewModel(errand: errand))
        }
        .task {
            await viewModel.loadErrands()
        }
    }
}
