#if DEBUG
import Foundation

/// Mock data for previews and debug mode. Available only in DEBUG builds.
enum PreviewData {

    // MARK: - Metadata

    static let metadata1 = WatchMetadata(
        path: "/Users/dev/projects/my-awesome-app",
        host: "MacBook-Pro.local",
        version: "1.2.3",
        name: "my-awesome-app",
        os: "darwin",
        summary: .init(text: "Implementing user authentication with OAuth2", updatedAt: Date().timeIntervalSince1970),
        machineId: "machine-001",
        claudeSessionId: "claude-sess-001",
        tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep"],
        homeDir: "/Users/dev",
        happyHomeDir: "/Users/dev/.happy"
    )

    static let metadata2 = WatchMetadata(
        path: "/Users/dev/projects/api-server",
        host: "iMac.local",
        name: "api-server",
        os: "darwin",
        summary: .init(text: "Refactoring database queries for performance", updatedAt: Date().timeIntervalSince1970)
    )

    static let metadata3 = WatchMetadata(
        path: "/home/user/web-frontend",
        host: "linux-dev",
        name: "web-frontend",
        os: "linux"
    )

    // MARK: - Agent States

    static let agentStateIdle = WatchAgentState(
        controlledByUser: false,
        requests: nil,
        completedRequests: nil
    )

    static let agentStatePaused = WatchAgentState(
        controlledByUser: true,
        requests: nil,
        completedRequests: nil
    )

    static let agentStateWithPermission = WatchAgentState(
        controlledByUser: false,
        requests: [
            "req-001": .init(
                id: "req-001",
                tool: "Bash",
                arguments: AnyCodable(["command": "rm -rf node_modules && npm install"]),
                createdAt: Date().timeIntervalSince1970
            ),
        ],
        completedRequests: nil
    )

    static let agentStateMultiplePermissions = WatchAgentState(
        controlledByUser: false,
        requests: [
            "req-001": .init(
                id: "req-001",
                tool: "Bash",
                arguments: AnyCodable(["command": "npm test"]),
                createdAt: Date().timeIntervalSince1970 - 30
            ),
            "req-002": .init(
                id: "req-002",
                tool: "Write",
                arguments: AnyCodable(["file_path": "/src/auth.ts", "content": "export class AuthService { ... }"]),
                createdAt: Date().timeIntervalSince1970 - 10
            ),
        ],
        completedRequests: nil
    )

    // MARK: - Sessions

    static let sessionWorking = WatchSession(
        id: "session-001",
        seq: 42,
        createdAt: Date().timeIntervalSince1970 - 3600,
        updatedAt: Date().timeIntervalSince1970,
        active: true,
        activeAt: Date().timeIntervalSince1970,
        metadata: metadata1,
        metadataVersion: 5,
        agentState: agentStateIdle,
        agentStateVersion: 12,
        thinking: false,
        thinkingAt: 0,
        presence: .online,
        permissionMode: .default
    )

    static let sessionThinking = WatchSession(
        id: "session-002",
        seq: 18,
        createdAt: Date().timeIntervalSince1970 - 7200,
        updatedAt: Date().timeIntervalSince1970,
        active: true,
        activeAt: Date().timeIntervalSince1970,
        metadata: metadata2,
        metadataVersion: 3,
        agentState: agentStateIdle,
        agentStateVersion: 8,
        thinking: true,
        thinkingAt: Date().timeIntervalSince1970,
        presence: .online,
        permissionMode: nil
    )

    static let sessionNeedsApproval = WatchSession(
        id: "session-003",
        seq: 7,
        createdAt: Date().timeIntervalSince1970 - 1800,
        updatedAt: Date().timeIntervalSince1970,
        active: true,
        activeAt: Date().timeIntervalSince1970,
        metadata: metadata1,
        metadataVersion: 2,
        agentState: agentStateWithPermission,
        agentStateVersion: 4,
        thinking: false,
        thinkingAt: 0,
        presence: .online,
        permissionMode: .default
    )

    static let sessionIdle = WatchSession(
        id: "session-004",
        seq: 3,
        createdAt: Date().timeIntervalSince1970 - 14400,
        updatedAt: Date().timeIntervalSince1970 - 600,
        active: true,
        activeAt: Date().timeIntervalSince1970 - 600,
        metadata: metadata3,
        metadataVersion: 1,
        agentState: nil,
        agentStateVersion: 0,
        thinking: false,
        thinkingAt: 0,
        presence: .online,
        permissionMode: nil
    )

    static let sessionOffline = WatchSession(
        id: "session-005",
        seq: 1,
        createdAt: Date().timeIntervalSince1970 - 86400,
        updatedAt: Date().timeIntervalSince1970 - 3600,
        active: true,
        activeAt: Date().timeIntervalSince1970 - 3600,
        metadata: metadata2,
        metadataVersion: 2,
        agentState: nil,
        agentStateVersion: 0,
        thinking: false,
        thinkingAt: 0,
        presence: .lastSeen(Date().timeIntervalSince1970 - 3600),
        permissionMode: nil
    )

    static let sessionCompleted = WatchSession(
        id: "session-006",
        seq: 50,
        createdAt: Date().timeIntervalSince1970 - 172800,
        updatedAt: Date().timeIntervalSince1970 - 7200,
        active: false,
        activeAt: Date().timeIntervalSince1970 - 7200,
        metadata: metadata3,
        metadataVersion: 1,
        agentState: nil,
        agentStateVersion: 0,
        thinking: false,
        thinkingAt: 0,
        presence: .lastSeen(Date().timeIntervalSince1970 - 7200),
        permissionMode: nil
    )

    static let allSessions = [
        sessionNeedsApproval,
        sessionWorking,
        sessionThinking,
        sessionIdle,
        sessionOffline,
        sessionCompleted,
    ]
}
#endif
