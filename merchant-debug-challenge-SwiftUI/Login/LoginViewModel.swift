//
//  LoginViewModel.swift
//  MockCardSwitcher
//
//  Created by Isaiah Schatzline on 3/5/26.
//

import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var requireOTP = false
    @Published var otpCode = ""
    @Published var showOTPEntry = false
    @Published var errorText: String?

    let merchant: Merchant
    private var loginStartedSubscriptionId: UUID?

    init(merchant: Merchant) {
        self.merchant = merchant
    }

    deinit {
        removeEventSubscription()
    }

    var title: String {
        "Login - \(merchant.name)"
    }

    func onAppear() {
        guard loginStartedSubscriptionId == nil else { return } // prevent duplicate subscriptions

        loginStartedSubscriptionId = MockPlatformEventBus.shared.subscribe { [weak self] event, _ in
            guard event == .loginStarted else { return }
            DispatchQueue.main.async {
                _ = self?.title
            }
        }
    }

    func onDisappear() {
        removeEventSubscription()
    }

    private func removeEventSubscription() {
        guard let id = loginStartedSubscriptionId else { return }
        MockPlatformEventBus.shared.unsubscribe(id)
        loginStartedSubscriptionId = nil
    }

    func loginTapped() -> AppRoute? {
        errorText = nil

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        MockPlatformEventBus.shared.emit(
            .loginStarted,
            metadata: ["merchantId": "\(merchant.id)", "merchantName": merchant.name]
        )

        guard !trimmedUsername.isEmpty && !trimmedPassword.isEmpty else {
            errorText = "Username and password are required."
            return nil
        }

        if requireOTP {
            showOTPEntry = true
            MockPlatformEventBus.shared.emit(
                .otpRequired,
                metadata: ["merchantId": "\(merchant.id)", "merchantName": merchant.name]
            )
            return nil
        }

        return completeAuthentication(username: trimmedUsername)
    }

    func submitOTPTapped() -> AppRoute? {
        guard otpCode.trimmingCharacters(in: .whitespacesAndNewlines) == "1234" else {
            errorText = "Invalid OTP. Use 1234."
            return nil
        }

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return completeAuthentication(username: trimmedUsername)
    }

    private func completeAuthentication(username: String) -> AppRoute {
        let accountId = "merchant:\(merchant.id):\(username)"
        let taskId = UUID().uuidString

        MockPlatformEventBus.shared.emit(
            .authenticated,
            metadata: [
                "merchantId": "\(merchant.id)",
                "merchantName": merchant.name,
                "accountId": accountId,
                "taskId": taskId
            ]
        )

        return .card(merchant: merchant, accountId: accountId, taskId: taskId)
    }
}
