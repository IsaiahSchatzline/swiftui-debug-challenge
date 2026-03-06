//
//  StartScreenViewModel.swift
//  MockCardSwitcher
//
//  Created by Isaiah Schatzline on 3/5/26.
//

import SwiftUI
import Combine

final class StartScreenViewModel: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var showSessionAlert = false
    @Published var showCreateSessionConfirmation = false
    @Published var now = Date()

    private var eventSubscriptionId: UUID?

    var sessionStatusText: String {
        guard let expiry = SessionStore.shared.expiryDate, SessionStore.shared.isSessionActive else {
            return "Session: Not Created"
        }

        let remaining = max(0, Int(expiry.timeIntervalSince(now)))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "Session: Active (expires in %02d:%02d)", minutes, seconds)
    }

    func onAppear() {
        LogStore.shared.log(category: .lifecycle, message: "Start screen loaded")
        eventSubscriptionId = MockPlatformEventBus.shared.subscribe { [weak self] event, _ in
            guard event == .refreshSessionRequest else { return }
            DispatchQueue.main.async {
                self?.handleRefreshSessionRequest()
            }
        }
    }

    func onDisappear() {
        if let eventSubscriptionId {
            MockPlatformEventBus.shared.unsubscribe(eventSubscriptionId)
            self.eventSubscriptionId = nil
        }
    }

    func tick(_ value: Date) {
        now = value
    }

    func startTapped() {
        if SessionStore.shared.isSessionActive {
            path.append(.merchants)
        } else {
            showSessionAlert = true
        }
    }

    func createSessionTapped() {
        _ = SessionService.shared.createSession(externalUserId: "demo_user", type: "card_switcher")
        now = Date()
        showCreateSessionConfirmation = true
    }

    func logsTapped() {
        path.append(.logs)
    }

    private func handleRefreshSessionRequest() {
        guard let sessionId = SessionStore.shared.sessionId else { return }
        _ = SessionService.shared.extendSession(sessionId: sessionId)
        now = Date()
    }
}
