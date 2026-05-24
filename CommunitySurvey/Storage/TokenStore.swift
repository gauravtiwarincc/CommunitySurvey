import Foundation

protocol TokenStoreProtocol: Sendable {
    func save(session: AuthSession)
    func loadSession() -> AuthSession?
    func clear()
}

struct TokenStore: TokenStoreProtocol {
    private let keychain: KeychainManaging
    private let key = "auth.session"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(keychain: KeychainManaging) {
        self.keychain = keychain
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save(session: AuthSession) {
        do {
            let data = try encoder.encode(session)
            try keychain.save(data, for: key)
        } catch {
            AppLogger.security.error("Failed to save session: \(error.localizedDescription, privacy: .public)")
        }
    }

    func loadSession() -> AuthSession? {
        do {
            guard let data = try keychain.load(key: key) else { return nil }
            return try decoder.decode(AuthSession.self, from: data)
        } catch {
            AppLogger.security.error("Failed to load session: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    func clear() {
        do { try keychain.delete(key: key) } catch {
            AppLogger.security.error("Failed to clear session: \(error.localizedDescription, privacy: .public)")
        }
    }
}
