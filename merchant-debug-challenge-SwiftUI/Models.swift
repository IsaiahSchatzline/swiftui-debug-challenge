import Foundation

struct Merchant: Hashable {
    let id: Int
    let name: String
}

struct CreditCard: Hashable {
    let id: String
    let displayName: String
    let number: String
    let expiration: String
    let cvv: String
}

struct Address: Hashable {
    let line1: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
}

struct User: Hashable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let address: Address
}

struct SwitchCardRequest: Hashable {
    let user: User
    let card: CreditCard
    let taskId: String
    let merchantId: Int
    let accountId: String
}

struct SwitchCardSuccessResponse: Hashable {
    let success: Bool
    let message: String
    let taskId: String
}
