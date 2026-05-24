import Foundation

enum APIError: Error, Equatable, LocalizedError, Sendable {
    case invalidURL
    case decodingError
    case unauthorized
    case serverError(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .decodingError: return "Unable to decode server response."
        case .unauthorized: return "Session expired. Please login again."
        case .serverError(let message): return message
        case .transport(let message): return message
        }
    }
}
