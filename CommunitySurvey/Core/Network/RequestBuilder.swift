import Foundation

struct RequestBuilder: Sendable {
    let environment: APIEnvironment
    let encoder: JSONEncoder

    init(environment: APIEnvironment, encoder: JSONEncoder = JSONEncoder()) {
        self.environment = environment
        self.encoder = encoder
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func build(endpoint: Endpoint) throws -> URLRequest {
        let pathParts = endpoint.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
        let path = String(pathParts.first ?? "")
        var components = URLComponents(url: environment.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        var queryItems = endpoint.queryItems
        if pathParts.count > 1, let queryComponents = URLComponents(string: "?\(pathParts[1])")?.queryItems {
            queryItems.append(contentsOf: queryComponents)
        }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components?.url else {
            throw AppError.network("Invalid API URL.")
        }

        var request = URLRequest(url: url, timeoutInterval: environment.requestTimeout)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        request.setValue("iOS", forHTTPHeaderField: "X-Client-Platform")
        endpoint.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        return request
    }
}

private struct AnyEncodable: Encodable {
    private let encodeBody: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        self.encodeBody = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeBody(encoder)
    }
}
