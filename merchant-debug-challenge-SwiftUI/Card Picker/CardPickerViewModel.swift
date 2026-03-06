//
//  CardPickerViewModel.swift
//  MockCardSwitcher
//
//  Created by Isaiah Schatzline on 3/5/26.
//

import SwiftUI
import Combine

final class CardPickerViewModel: ObservableObject {
    @Published var selectedCardId: String?
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var toastMessage: String?

    let merchant: Merchant
    let accountId: String
    let taskId: String

    let cards: [CreditCard] = [
        CreditCard(id: "visa_1111", displayName: "Visa •••• 1111", number: "4111111111111111", expiration: "12/2030", cvv: "123"),
        CreditCard(id: "mc_2222", displayName: "Mastercard •••• 2222", number: "5555555555554444", expiration: "11/2031", cvv: "123"),
        CreditCard(id: "amex_3333", displayName: "AmEx •••• 3333", number: "378282246310005", expiration: "10/2032", cvv: "1234"),
        CreditCard(id: "disc_4444", displayName: "Discover •••• 4444", number: "6011111111111117", expiration: "09/2030", cvv: "123"),
        CreditCard(id: "cap1_5555", displayName: "Capital One •••• 5555", number: "4242424242424242", expiration: "08/2031", cvv: "123")
    ]

    init(merchant: Merchant, accountId: String, taskId: String) {
        self.merchant = merchant
        self.accountId = accountId
        self.taskId = taskId
    }

    var title: String {
        "Select Card - \(merchant.name)"
    }

    func onAppear() {
        selectedCardId = CardSwitcherStore.shared.selectedCardId(merchantId: merchant.id, accountId: accountId)
    }

    func cardTapped(_ cardId: String) {
        selectedCardId = cardId
    }

    func saveTapped() {
        guard let selectedCardId, let selectedCard = cards.first(where: { $0.id == selectedCardId }) else {
            errorMessage = "Choose one card before saving."
            return
        }

        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.performSave(card: selectedCard)
        }
    }

    private func performSave(card: CreditCard) {
        CardSwitcherStore.shared.saveSelectedCardId(card.id, merchantId: merchant.id, accountId: accountId)

        let testUser = User(
            firstName: "Test",
            lastName: "User",
            phoneNumber: "+15555551234",
            address: Address(
                line1: "123 Demo Street",
                city: "New York",
                state: "NY",
                postalCode: "10001",
                country: "US"
            )
        )

        let request = SwitchCardRequest(
            user: testUser,
            card: card,
            taskId: taskId,
            merchantId: merchant.id,
            accountId: accountId
        )

        let result = MockAPIClient.shared.switchCard(request: request)
        isSaving = false

        switch result {
        case .success:
            toastMessage = "Card saved successfully"
        case .failure(let error):
            errorMessage = error.errorMessage
        }
    }
}
