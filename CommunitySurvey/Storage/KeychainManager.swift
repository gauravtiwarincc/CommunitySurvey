import Foundation
import Security

protocol KeychainManaging: Sendable {
    func save(_ data: Data, for key: String) throws
    func load(key: String) throws -> Data?
    func delete(key: String) throws
}

struct KeychainManager: KeychainManaging {
    private let service: String

    init(service: String) {
        self.service = service
    }

    func save(_ data: Data, for key: String) throws {
        try delete(key: key)
        var query = baseQuery(key: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw AppError.keychain(status) }
    }

    func load(key: String) throws -> Data? {
        var query = baseQuery(key: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw AppError.keychain(status) }
        return result as? Data
    }

    func delete(key: String) throws {
        let status = SecItemDelete(baseQuery(key: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw AppError.keychain(status) }
    }

    private func baseQuery(key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
