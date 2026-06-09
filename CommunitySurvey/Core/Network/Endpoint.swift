import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var requiresAuthentication: Bool { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Encodable? { nil }
    var requiresAuthentication: Bool { true }
}

struct APIEndpoint: Endpoint {
    let path: String
    let method: HTTPMethod
    let body: Encodable?
    let requiresAuthentication: Bool
    let queryItems: [URLQueryItem]
    let headers: [String: String]

    init(path: String, method: HTTPMethod = .get, body: Encodable? = nil, requiresAuthentication: Bool = true, queryItems: [URLQueryItem] = [], headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.body = body
        self.requiresAuthentication = requiresAuthentication
        self.queryItems = queryItems
        self.headers = headers
    }
}
