import Foundation

enum MockPlatformEvent: String {
    case refreshSessionRequest = "REFRESH_SESSION_REQUEST"
    case authenticated = "AUTHENTICATED"
    case merchantClicked = "MERCHANT_CLICKED"
    case loginStarted = "LOGIN_STARTED"
    case otpRequired = "OTP_REQUIRED"
    case questionsRequired = "QUESTIONS_REQUIRED"
}
