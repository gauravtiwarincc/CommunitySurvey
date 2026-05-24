import Foundation

protocol UserDefaultsStoreProtocol: Sendable {
    func bool(for key: String) -> Bool
    func set(_ value: Bool, for key: String)
    func string(for key: String) -> String?
    func set(_ value: String?, for key: String)
}

struct UserDefaultsStore: UserDefaultsStoreProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bool(for key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func set(_ value: Bool, for key: String) {
        defaults.set(value, forKey: key)
    }

    func string(for key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String?, for key: String) {
        defaults.set(value, forKey: key)
    }
}
