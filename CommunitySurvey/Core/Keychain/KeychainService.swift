import Foundation
import Security

final class KeychainService: @unchecked Sendable {
    private let service: String
    private let tokenKey = "jwt.token"

    init(service: String = "com.verifiedopinionnetwork.jwt") {
        self.service = service
    }

    func save(token: String) throws {
        guard let data = token.data(using: .utf8) else { throw APIError.serverError("Invalid token encoding.") }
        try deleteToken()
        var query = baseQuery(account: tokenKey)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw AppError.keychain(status) }
    }

    func getToken() -> String? {
        var query = baseQuery(account: tokenKey)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func deleteToken() throws {
        let status = SecItemDelete(baseQuery(account: tokenKey) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw AppError.keychain(status) }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
