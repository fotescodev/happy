import Foundation
import Security

/// Keychain wrapper for storing auth tokens and encryption keys
final class KeychainHelper: Sendable {
    static let shared = KeychainHelper()

    private let service = "com.slopus.happy.watch"

    private init() {}

    // MARK: - Generic Operations

    func save(_ data: Data, forKey key: String) -> Bool {
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    // MARK: - Typed Convenience

    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, forKey: key)
    }

    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Well-Known Keys

    enum Key {
        static let authToken = "auth_token"
        static let serverUrl = "server_url"
        static let masterSecret = "master_secret"
        static let sessionKeysPrefix = "session_key_"
    }

    // MARK: - Session Keys (for REST fallback encryption)

    func saveSessionKey(_ keyData: Data, sessionId: String) -> Bool {
        save(keyData, forKey: Key.sessionKeysPrefix + sessionId)
    }

    func loadSessionKey(sessionId: String) -> Data? {
        load(forKey: Key.sessionKeysPrefix + sessionId)
    }

    func deleteSessionKey(sessionId: String) {
        delete(forKey: Key.sessionKeysPrefix + sessionId)
    }

    // MARK: - Clear All

    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
