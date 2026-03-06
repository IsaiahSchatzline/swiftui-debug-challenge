import Foundation

final class SessionStore {
    static let shared = SessionStore()

    private let defaults = UserDefaults.standard
    private let sessionIdKey = "cardswitcher.session.id"
    private let sessionExpiryKey = "cardswitcher.session.expiry"
    private var refreshTimer: Timer?

    private(set) var sessionId: String? {
        didSet {
            defaults.set(sessionId, forKey: sessionIdKey)
        }
    }

    private(set) var expiryDate: Date? {
        didSet {
            defaults.set(expiryDate, forKey: sessionExpiryKey)
            scheduleRefreshEvent()
        }
    }

    private init() {
        sessionId = defaults.string(forKey: sessionIdKey)
        expiryDate = defaults.object(forKey: sessionExpiryKey) as? Date
        scheduleRefreshEvent()
    }

    var isSessionActive: Bool {
        guard let expiryDate else { return false }
        return Date() < expiryDate
    }

    func setSession(sessionId: String, expiryDate: Date) {
        self.sessionId = sessionId
        self.expiryDate = expiryDate
    }

    func extendSession() -> Date? {
        guard sessionId != nil else { return nil }
        let newExpiry = Date().addingTimeInterval(30 * 60)
        expiryDate = newExpiry
        return newExpiry
    }

    private func scheduleRefreshEvent() {
        refreshTimer?.invalidate()
        refreshTimer = nil

        guard let expiryDate, isSessionActive else { return }

        let fireDate = expiryDate.addingTimeInterval(-5)
        let interval = fireDate.timeIntervalSinceNow
        guard interval > 0 else { return }

        DispatchQueue.main.async {
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                guard self.isSessionActive else { return }
                MockPlatformEventBus.shared.emit(.refreshSessionRequest)
                LogStore.shared.log(
                    category: .lifecycle,
                    message: "REFRESH_SESSION_REQUEST fired for active session"
                )
            }
        }
    }
}

final class SessionService {
    static let shared = SessionService()

    private init() {}

    @discardableResult
    func createSession(externalUserId: String, type: String) -> String {
        let sessionId = UUID().uuidString
        let expiry = Date().addingTimeInterval(30 * 60)
        SessionStore.shared.setSession(sessionId: sessionId, expiryDate: expiry)
        LogStore.shared.log(
            category: .network,
            message: "Mock POST /session/create external_user_id=\(externalUserId) type=\(type) -> expires=\(expiry)"
        )
        return sessionId
    }

    func extendSession(sessionId: String) -> Date? {
        guard SessionStore.shared.sessionId == sessionId else {
            LogStore.shared.log(
                category: .sdkError,
                message: "Mock POST /session/extend failed: invalid session id"
            )
            return nil
        }

        let expiry = SessionStore.shared.extendSession()
        if let expiry {
            LogStore.shared.log(
                category: .network,
                message: "Mock POST /session/extend -> new expiry=\(expiry)"
            )
        }
        return expiry
    }
}
