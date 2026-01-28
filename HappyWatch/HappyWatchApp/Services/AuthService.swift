import Foundation

/// Manages authentication state: JWT token + encryption keys stored in Keychain
@Observable
final class AuthService {
    private(set) var isAuthenticated = false
    private(set) var serverUrl: String?

    init() {
        // Load persisted auth state
        if let token = KeychainHelper.shared.loadString(forKey: KeychainHelper.Key.authToken),
           !token.isEmpty {
            isAuthenticated = true
            serverUrl = KeychainHelper.shared.loadString(forKey: KeychainHelper.Key.serverUrl)
        }
    }

    // MARK: - Auth Lifecycle

    /// Called when iPhone transfers auth credentials via WatchConnectivity
    func authenticate(token: String, serverUrl: String) {
        _ = KeychainHelper.shared.saveString(token, forKey: KeychainHelper.Key.authToken)
        _ = KeychainHelper.shared.saveString(serverUrl, forKey: KeychainHelper.Key.serverUrl)
        self.serverUrl = serverUrl
        self.isAuthenticated = true
        AppGroupStorage.shared.isAuthenticated = true
        AppGroupStorage.shared.serverUrl = serverUrl
    }

    /// Store session encryption keys received from iPhone (for REST fallback)
    func storeSessionKeys(_ keys: [String: Data]) {
        for (sessionId, keyData) in keys {
            _ = KeychainHelper.shared.saveSessionKey(keyData, sessionId: sessionId)
        }
    }

    /// Retrieve the auth token for REST API calls
    var authToken: String? {
        KeychainHelper.shared.loadString(forKey: KeychainHelper.Key.authToken)
    }

    /// Retrieve session encryption key for standalone decryption
    func sessionKey(for sessionId: String) -> Data? {
        KeychainHelper.shared.loadSessionKey(sessionId: sessionId)
    }

    /// Clear all credentials (logout / unpair)
    func logout() {
        KeychainHelper.shared.clearAll()
        isAuthenticated = false
        serverUrl = nil
        AppGroupStorage.shared.isAuthenticated = false
    }
}
