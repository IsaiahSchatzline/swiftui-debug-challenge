import SwiftUI

struct CardPickerView: View {
    @Binding var path: [AppRoute]
    @StateObject private var viewModel: CardPickerViewModel

    init(merchant: Merchant, accountId: String, taskId: String, path: Binding<[AppRoute]>) {
        _path = path
        _viewModel = StateObject(wrappedValue: CardPickerViewModel(merchant: merchant, accountId: accountId, taskId: taskId))
    }

    var body: some View {
        VStack(spacing: 0) {
            List(viewModel.cards, id: \.id) { card in
                Button {
                    viewModel.selectedCardId = card.id
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.displayName)
                            Text("Test card only")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if viewModel.selectedCardId == card.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.insetGrouped)

            VStack {
                Button {
                    viewModel.saveTapped()
                } label: {
                    HStack {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                        if viewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Back to Start") {
                    path.removeAll()
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .alert("Save Failed", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .toast(message: $viewModel.toastMessage)
    }
}
