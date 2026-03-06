import Foundation

struct MockAPIError: Error {
    let errorType: String
    let errorCode: String
    let errorMessage: String
}

extension MockAPIError {
    static func missingField(_ field: String) -> MockAPIError {
        MockAPIError(
            errorType: "INVALID_INPUT",
            errorCode: "MISSING_REQUIRED_FIELD",
            errorMessage: "Missing required field: \(field)"
        )
    }

    static func invalidField(_ field: String, reason: String) -> MockAPIError {
        MockAPIError(
            errorType: "INVALID_INPUT",
            errorCode: "INVALID_FIELD",
            errorMessage: "Invalid \(field): \(reason)"
        )
    }

    static let ongoingOperation = MockAPIError(
        errorType: "CONFLICT",
        errorCode: "ONGOING_OPERATION",
        errorMessage: "Another switch operation is still in progress. Please try again."
    )
}
