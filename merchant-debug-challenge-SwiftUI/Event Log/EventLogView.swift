import SwiftUI

struct EventLogView: View {
    @StateObject private var viewModel = EventLogViewModel()

    var body: some View {
        List(viewModel.entries.indices, id: \.self) { index in
            let entry = viewModel.entries[index]
            VStack(alignment: .leading, spacing: 4) {
                Text("[\(entry.category.rawValue)] \(entry.message)")
                    .font(.body)
                Text(viewModel.timeString(entry.timestamp))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    viewModel.clearTapped()
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: LogStore.didChangeNotification)) { _ in
            viewModel.reloadEntries()
        }
    }
}
