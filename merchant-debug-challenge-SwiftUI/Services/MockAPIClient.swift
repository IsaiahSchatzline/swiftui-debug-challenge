import Foundation

final class MockAPIClient {
    static let shared = MockAPIClient()

    private var lastRequestTimeByTaskId: [String: Date] = [:]
    private let minRequestGap: TimeInterval = 1.0

    private init() {}

    func switchCard(request: SwitchCardRequest) -> Result<SwitchCardSuccessResponse, MockAPIError> {
        let redactedCard = redactCardNumber(request.card.number)
        LogStore.shared.log(
            category: .mockApi,
            message: "Mock POST /card attempt merchant=\(request.merchantId) account=\(request.accountId) task_id=\(request.taskId) card=\(redactedCard)"
        )

        if isOngoingOperation(taskId: request.taskId) {
            LogStore.shared.log(category: .sdkError, message: "Mock POST /card failed: ONGOING_OPERATION")
            return .failure(.ongoingOperation)
        }

        if let error = validate(request: request) {
            LogStore.shared.log(
                category: .sdkError,
                message: "Mock POST /card failed: \(error.errorCode) \(error.errorMessage)"
            )
            return .failure(error)
        }

        let response = SwitchCardSuccessResponse(success: true, message: "Card switched", taskId: request.taskId)
        LogStore.shared.log(
            category: .mockApi,
            message: "Mock POST /card success task_id=\(request.taskId) card=\(redactedCard)"
        )
        return .success(response)
    }

    private func isOngoingOperation(taskId: String) -> Bool {
        let now = Date()
        defer {
            lastRequestTimeByTaskId[taskId] = now
        }

        guard let last = lastRequestTimeByTaskId[taskId] else {
            return false
        }
        return now.timeIntervalSince(last) < minRequestGap
    }

    private func validate(request: SwitchCardRequest) -> MockAPIError? {
        if request.taskId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("task_id")
        }

        if request.user.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.first_name")
        }
        if request.user.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.last_name")
        }
        if request.user.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.phone_number")
        }

        if request.user.address.line1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.address.line1")
        }
        if request.user.address.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.address.city")
        }
        if request.user.address.state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.address.state")
        }
        if request.user.address.postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.address.postal_code")
        }
        if request.user.address.country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingField("user.address.country")
        }

        let number = request.card.number.trimmingCharacters(in: .whitespacesAndNewlines)
        if number.isEmpty {
            return .missingField("card.number")
        }
        if number.contains(where: { !$0.isNumber }) {
            return .invalidField("card.number", reason: "must contain only digits")
        }
        if !isValidLuhn(number) {
            return .invalidField("card.number", reason: "failed Luhn check")
        }

        let cvv = request.card.cvv.trimmingCharacters(in: .whitespacesAndNewlines)
        if cvv.isEmpty {
            return .missingField("card.cvv")
        }
        if cvv.contains(where: { !$0.isNumber }) || !(3...4).contains(cvv.count) {
            return .invalidField("card.cvv", reason: "must be numeric and 3 to 4 digits")
        }

        let expiration = request.card.expiration.trimmingCharacters(in: .whitespacesAndNewlines)
        if expiration.isEmpty {
            return .missingField("card.expiration")
        }
        if !isValidExpiration(expiration) {
            return .invalidField("card.expiration", reason: "must be MM/YY or MM/YYYY and not expired")
        }

        return nil
    }

    private func redactCardNumber(_ number: String) -> String {
        let last4 = String(number.suffix(4))
        return "****\(last4)"
    }

    private func isValidLuhn(_ number: String) -> Bool {
        let digits = number.compactMap { Int(String($0)) }
        guard digits.count == number.count else { return false }

        let sum = digits.reversed().enumerated().reduce(0) { partial, pair in
            let (index, digit) = pair
            if index % 2 == 1 {
                let doubled = digit * 2
                return partial + (doubled > 9 ? doubled - 9 : doubled)
            }
            return partial + digit
        }

        return sum % 10 == 0
    }

    private func isValidExpiration(_ value: String) -> Bool {
        let parts = value.split(separator: "/")
        guard parts.count == 2, let month = Int(parts[0]), (1...12).contains(month) else {
            return false
        }

        let yearPart = String(parts[1])
        let fullYear: Int
        if yearPart.count == 2, let yy = Int(yearPart) {
            fullYear = 2000 + yy
        } else if yearPart.count == 4, let yyyy = Int(yearPart) {
            fullYear = yyyy
        } else {
            return false
        }

        var components = DateComponents()
        components.year = fullYear
        components.month = month + 1
        components.day = 1

        let calendar = Calendar.current
        guard let firstDayNextMonth = calendar.date(from: components) else {
            return false
        }

        return firstDayNextMonth > Date()
    }
}
