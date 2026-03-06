import Foundation

final class MockPlatformEventBus {
    static let shared = MockPlatformEventBus()

    typealias EventHandler = (MockPlatformEvent, [String: String]) -> Void

    private var subscribers: [UUID: EventHandler] = [:]
    private let queue = DispatchQueue(label: "com.cardswitcher.eventbus", attributes: .concurrent)

    private init() {}

    @discardableResult
    func subscribe(_ handler: @escaping EventHandler) -> UUID {
        let id = UUID()
        queue.async(flags: .barrier) {
            self.subscribers[id] = handler
        }
        return id
    }

    func unsubscribe(_ id: UUID) {
        queue.async(flags: .barrier) {
            self.subscribers.removeValue(forKey: id)
        }
    }

    func emit(_ event: MockPlatformEvent, metadata: [String: String] = [:]) {
        LogStore.shared.log(
            category: .sdkEvent,
            message: "\(event.rawValue) \(metadata.isEmpty ? "" : "metadata=\(metadata)")"
        )

        queue.sync {
            for handler in subscribers.values {
                handler(event, metadata)
            }
        }
    }
}
