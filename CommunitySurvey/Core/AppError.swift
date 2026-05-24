import Foundation

enum AppError: Error, Equatable, LocalizedError, Sendable {
    case validation(String)
    case network(String)
    case unauthorized
    case decoding
    case offline
    case keychain(OSStatus)
    case server(code: Int, message: String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .validation(let message), .network(let message), .unknown(let message):
            return message
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .decoding:
            return "We could not process the server response."
        case .offline:
            return "You appear to be offline. Please check your connection."
        case .keychain:
            return "Secure storage is unavailable."
        case .server(_, let message):
            return message
        }
    }
}

enum LoadableState<Value: Equatable>: Equatable {
    case idle
    case loading
    case empty
    case success(Value)
    case failure(AppError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
