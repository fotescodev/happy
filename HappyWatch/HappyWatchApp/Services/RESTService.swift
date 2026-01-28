import Foundation

/// Direct HTTP client for cellular fallback when iPhone is not reachable
final class RESTService: Sendable {
    private let session = URLSession.shared

    /// Fetch active sessions from the server
    func fetchActiveSessions(serverUrl: String, token: String) async throws -> [WatchSessionDTO] {
        let url = URL(string: "\(serverUrl)/v2/sessions/active")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RESTError.invalidResponse
        }
        return try JSONDecoder().decode([WatchSessionDTO].self, from: data)
    }

    /// Send permission decision directly to server (requires encryption)
    func sendPermissionDecision(
        serverUrl: String,
        token: String,
        sessionId: String,
        requestId: String,
        decision: PermissionDecision,
        encryptedParams: String
    ) async throws {
        let url = URL(string: "\(serverUrl)/v1/sessions/\(sessionId)/rpc")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        let body: [String: Any] = [
            "method": "\(sessionId):permission",
            "params": encryptedParams,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RESTError.rpcFailed
        }
    }

    /// Register push notification token
    func registerPushToken(serverUrl: String, token: String, pushToken: String) async throws {
        let url = URL(string: "\(serverUrl)/v1/push-tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "token": pushToken,
            "platform": "watchos",
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RESTError.invalidResponse
        }
    }
}

enum RESTError: Error, LocalizedError {
    case invalidResponse
    case rpcFailed
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Invalid server response"
        case .rpcFailed: "RPC call failed"
        case .unauthorized: "Authentication required"
        }
    }
}

/// Server DTO for sessions (encrypted fields as strings, not yet decrypted)
struct WatchSessionDTO: Codable, Sendable {
    let id: String
    var seq: Int
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var active: Bool
    var activeAt: TimeInterval
    var metadata: String?  // Encrypted
    var metadataVersion: Int
    var agentState: String?  // Encrypted
    var agentStateVersion: Int
}
