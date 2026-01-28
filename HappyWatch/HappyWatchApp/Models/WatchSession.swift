import Foundation

/// Mirrors storageTypes.ts Session interface
struct WatchSession: Codable, Sendable, Identifiable, Equatable {
    let id: String
    var seq: Int
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var active: Bool
    var activeAt: TimeInterval
    var metadata: WatchMetadata?
    var metadataVersion: Int
    var agentState: WatchAgentState?
    var agentStateVersion: Int
    var thinking: Bool
    var thinkingAt: TimeInterval
    var presence: Presence
    var permissionMode: PermissionMode?

    /// Presence: "online" or a timestamp of last seen
    enum Presence: Codable, Sendable, Equatable {
        case online
        case lastSeen(TimeInterval)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self), str == "online" {
                self = .online
            } else if let ts = try? container.decode(TimeInterval.self) {
                self = .lastSeen(ts)
            } else {
                self = .lastSeen(0)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .online:
                try container.encode("online")
            case .lastSeen(let ts):
                try container.encode(ts)
            }
        }

        var isOnline: Bool {
            if case .online = self { return true }
            return false
        }
    }

    enum PermissionMode: String, Codable, Sendable {
        case `default`
        case acceptEdits
        case bypassPermissions
        case plan
        case readOnly = "read-only"
        case safeYolo = "safe-yolo"
        case yolo
    }

    /// Derived ClaudeState from current session state
    var claudeState: ClaudeState {
        ClaudeState.derive(from: self)
    }

    /// Display name for the session
    var displayName: String {
        metadata?.displayName ?? id.prefix(8).description
    }

    /// Whether session has pending permission requests
    var hasPendingApprovals: Bool {
        agentState?.hasPermissionRequests ?? false
    }

    /// Pending permission requests
    var pendingRequests: [WatchAgentState.PermissionRequest] {
        agentState?.pendingRequests ?? []
    }
}
