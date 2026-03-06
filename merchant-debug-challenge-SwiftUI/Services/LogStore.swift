import Foundation

enum LogCategory: String {
    case app
    case sdkEvent
    case sdkError
    case network
    case mockApi
    case lifecycle
}

struct LogEntry {
    let timestamp: Date
    let category: LogCategory
    let message: String
}

final class LogStore {
    static let shared = LogStore()
    static let didChangeNotification = Notification.Name("LogStoreDidChange")

    private var entries: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.cardswitcher.logstore")
    private let maxEntries = 500

    private init() {}

    func log(category: LogCategory, message: String) {
        queue.sync {
            if entries.count >= maxEntries {
                entries.removeFirst(entries.count - maxEntries + 1)
            }
            entries.append(LogEntry(timestamp: Date(), category: category, message: message))
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: LogStore.didChangeNotification, object: nil)
        }
    }

    func allEntries() -> [LogEntry] {
        queue.sync { entries }
    }

    func clear() {
        queue.sync {
            entries.removeAll()
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: LogStore.didChangeNotification, object: nil)
        }
    }
}
