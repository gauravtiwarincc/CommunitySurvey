import Foundation

enum APIEnvironment: String, CaseIterable, Sendable {
    case development
    case staging
    case production

    static var current: APIEnvironment {
        #if PRODUCTION
        return .production
        #elseif STAGING
        return .staging
        #else
        return .development
        #endif
    }

    var baseURL: URL {
        let candidate: String
        switch self {
        case .development:
            candidate = ProcessInfo.processInfo.environment["DEV_API_BASE_URL"] ?? Self.localBaseURL
        case .staging:
            candidate = ProcessInfo.processInfo.environment["STAGING_API_BASE_URL"] ?? Self.localBaseURL
        case .production:
            candidate = ProcessInfo.processInfo.environment["PROD_API_BASE_URL"] ?? Self.localBaseURL
        }
        return URL(string: candidate) ?? URL(fileURLWithPath: "/")
    }

    var requestTimeout: TimeInterval { 30 }
    var sslPinnedHosts: Set<String> { [baseURL.host].compactMap { $0 }.reduce(into: Set<String>()) { $0.insert($1) } }

    private static let localBaseURL = "http://127.0.0.1:3001/api"
}
