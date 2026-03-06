//
//  MerchantPickerViewModel.swift
//  MockCardSwitcher
//
//  Created by Isaiah Schatzline on 3/5/26.
//

import SwiftUI
import Combine

final class MerchantPickerViewModel: ObservableObject {
    let merchants: [Merchant] = [
        Merchant(id: 46, name: "Netflix"),
        Merchant(id: 99, name: "PayPal")
    ]

    func merchantTapped(_ merchant: Merchant) -> AppRoute {
        MockPlatformEventBus.shared.emit(
            .merchantClicked,
            metadata: ["merchantId": "\(merchant.id)", "merchantName": merchant.name]
        )
        return .login(merchant)
    }
}
