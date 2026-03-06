import Foundation

final class CardSwitcherStore {
    static let shared = CardSwitcherStore()

    private let defaults = UserDefaults.standard

    private init() {}

    func saveSelectedCardId(_ cardId: String, merchantId: Int, accountId: String) {
        defaults.set(cardId, forKey: key(for: merchantId, accountId: accountId))
        LogStore.shared.log(
            category: .app,
            message: "Saved card selection for merchant=\(merchantId), account=\(accountId), cardId=\(cardId)"
        )
    }

    func selectedCardId(merchantId: Int, accountId: String) -> String? {
        defaults.string(forKey: key(for: merchantId, accountId: accountId))
    }

    private func key(for merchantId: Int, accountId: String) -> String {
        "cardswitcher.\(merchantId).\(accountId)"
    }
}
