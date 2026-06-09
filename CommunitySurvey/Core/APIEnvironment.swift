import Foundation

enum APIEnvironment: String, CaseIterable, Sendable {
    case local
    case development
    case staging
    case production

    static var current: APIEnvironment {
        #if PRODUCTION
        return .production
        #elseif STAGING
        return .staging
        #elseif LOCAL
        return .local
        #else
        return .development
        #endif
    }

    var baseURL: URL {
        let candidate: String
        switch self {
        case .local:
            candidate = "http://127.0.0.1:3001/api"
        case .development:
            candidate = ProcessInfo.processInfo.environment["DEV_API_BASE_URL"] ?? Self.remoteBaseURL
        case .staging:
            candidate = ProcessInfo.processInfo.environment["STAGING_API_BASE_URL"] ?? Self.remoteBaseURL
        case .production:
            candidate = ProcessInfo.processInfo.environment["PROD_API_BASE_URL"] ?? Self.remoteBaseURL
        }
        return URL(string: candidate) ?? URL(fileURLWithPath: "/")
    }

    var requestTimeout: TimeInterval { 30 }
    var sslPinnedHosts: Set<String> { [baseURL.host].compactMap { $0 }.reduce(into: Set<String>()) { $0.insert($1) } }

    private static let remoteBaseURL = "https://thesentinel.in/api"
}
