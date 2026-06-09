import Foundation
import OSLog

@MainActor
protocol APIClientProtocol {
    func send<Response: Decodable>(_ endpoint: Endpoint, responseType: Response.Type) async throws -> Response
    func request<Response: Decodable, Body: Encodable>(path: String, method: HTTPMethod, body: Body?, requiresAuthentication: Bool, responseType: Response.Type) async throws -> Response
}

@MainActor
struct APIClient: APIClientProtocol {
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    private let interceptor: RequestIntercepting
    private let networkMonitor: NetworkMonitoring
    private let decoder: JSONDecoder
    private let maxRetryCount: Int

    init(environment: APIEnvironment, interceptor: RequestIntercepting, networkMonitor: NetworkMonitoring, session: URLSession = .shared, maxRetryCount: Int = 1) {
        self.session = session
        self.requestBuilder = RequestBuilder(environment: environment)
        self.interceptor = interceptor
        self.networkMonitor = networkMonitor
        self.maxRetryCount = maxRetryCount
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func request<Response: Decodable, Body: Encodable>(path: String, method: HTTPMethod, body: Body?, requiresAuthentication: Bool, responseType: Response.Type) async throws -> Response {
        let endpoint = APIEndpoint(path: path, method: method, body: body, requiresAuthentication: requiresAuthentication)
        return try await send(endpoint, responseType: responseType)
    }

    func send<Response: Decodable>(_ endpoint: Endpoint, responseType: Response.Type) async throws -> Response {
        guard await networkMonitor.isReachable else { throw APIError.transport("No network connection.") }
        var attempt = 0
        var lastError: Error?

        while attempt <= maxRetryCount {
            do {
                let request = try await interceptor.adapt(requestBuilder.build(endpoint: endpoint), endpoint: endpoint)
                logRequest(request, attempt: attempt)
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.transport("Invalid response.") }
                logResponse(httpResponse, data: data)
                return try decode(data, response: httpResponse, path: endpoint.path, as: responseType)
            } catch {
                logFailure(error, attempt: attempt)
                lastError = error
                guard attempt < maxRetryCount, shouldRetry(error) else { break }
                attempt += 1
                try await Task.sleep(for: .milliseconds(250 * attempt))
            }
        }
        throw map(lastError ?? APIError.transport("Request failed."))
    }

    private func decode<Response: Decodable>(_ data: Data, response: HTTPURLResponse, path: String, as type: Response.Type) throws -> Response {
        switch response.statusCode {
        case 200..<300:
            do { return try decoder.decode(type, from: data) } catch { throw APIError.decodingError }
        case 401:
            let errorResponse = try? decoder.decode(ServerErrorResponse.self, from: data)
            let message = errorResponse?.message ?? "Session expired. Please log in again."
            NotificationCenter.default.post(name: NSNotification.Name("UserSessionExpired"), object: nil, userInfo: ["message": message])
            throw APIError.unauthorized
        case 403:
            let errorResponse = try? decoder.decode(ServerErrorResponse.self, from: data)
            let message = errorResponse?.message ?? "Access forbidden."
            if path.contains("/auth") {
                NotificationCenter.default.post(name: NSNotification.Name("UserDeactivatedDuringAuth"), object: nil, userInfo: ["message": message])
            }
            throw APIError.serverError(message)
        default:
            let errorResponse = try? decoder.decode(ServerErrorResponse.self, from: data)
            throw APIError.serverError(errorResponse?.message ?? "Server returned status \(response.statusCode).")
        }
    }

    private func shouldRetry(_ error: Error) -> Bool {
        if case APIError.unauthorized = error { return false }
        return true
    }

    private func map(_ error: Error) -> APIError {
        if let apiError = error as? APIError { return apiError }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotConnectToHost, .networkConnectionLost, .timedOut:
                return .transport("Could not connect to the server at https://thesentinel.in. Please check your internet connection or server status.")
            default:
                return .transport(urlError.localizedDescription)
            }
        }
        return .transport(error.localizedDescription)
    }

    private func logRequest(_ request: URLRequest, attempt: Int) {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "Invalid URL"
        let headers = sanitizedHeaders(request.allHTTPHeaderFields ?? [:])
        let body = prettyString(from: request.httpBody) ?? "<empty>"
        let message = """

        API REQUEST
        Attempt: \(attempt + 1)
        \(method) \(url)
        Headers: \(headers)
        Body: \(body)
        """
        AppLogger.network.debug("\(message, privacy: .public)")
        print(message)
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        let url = response.url?.absoluteString ?? "Invalid URL"
        let headers = sanitizedHeaders(response.allHeaderFields.reduce(into: [String: String]()) { partialResult, item in
            if let key = item.key as? String {
                partialResult[key] = String(describing: item.value)
            }
        })
        let body = prettyString(from: data) ?? "<empty>"
        let message = """

        API RESPONSE
        Status: \(response.statusCode)
        URL: \(url)
        Headers: \(headers)
        Body: \(body)
        """
        AppLogger.network.debug("\(message, privacy: .public)")
        print(message)
    }

    private func logFailure(_ error: Error, attempt: Int) {
        let message = """

        API FAILURE
        Attempt: \(attempt + 1)
        Error: \(error.localizedDescription)
        """
        AppLogger.network.error("\(message, privacy: .public)")
        print(message)
    }

    private func sanitizedHeaders(_ headers: [String: String]) -> [String: String] {
        headers.reduce(into: [String: String]()) { result, entry in
            if entry.key.caseInsensitiveCompare("Authorization") == .orderedSame {
                result[entry.key] = "Bearer <redacted>"
            } else {
                result[entry.key] = entry.value
            }
        }
    }

    private func prettyString(from data: Data?) -> String? {
        guard let data, !data.isEmpty else { return nil }
        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return String(data: data, encoding: .utf8)
    }
}

private struct ServerErrorResponse: Decodable {
    let message: String?
}
