import Foundation

/// Shared UserDefaults storage via App Group for widget data sharing
final class AppGroupStorage: @unchecked Sendable {
    static let shared = AppGroupStorage()

    private let suiteName = "group.com.slopus.happy.watch"
    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    // MARK: - Sessions Cache

    private static let sessionsKey = "cached_sessions"
    private static let lastSyncKey = "last_sync_timestamp"

    func saveSessions(_ sessions: [WatchSession]) {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: Self.sessionsKey)
        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastSyncKey)
    }

    func loadSessions() -> [WatchSession] {
        guard let data = defaults.data(forKey: Self.sessionsKey),
              let sessions = try? JSONDecoder().decode([WatchSession].self, from: data) else {
            return []
        }
        return sessions
    }

    var lastSyncTimestamp: TimeInterval? {
        let ts = defaults.double(forKey: Self.lastSyncKey)
        return ts > 0 ? ts : nil
    }

    // MARK: - Widget Data

    private static let approvalCountKey = "pending_approval_count"
    private static let activeCountKey = "active_session_count"
    private static let topSessionKey = "top_session_summary"

    func updateWidgetData(approvalCount: Int, activeCount: Int, topSession: String?) {
        defaults.set(approvalCount, forKey: Self.approvalCountKey)
        defaults.set(activeCount, forKey: Self.activeCountKey)
        defaults.set(topSession, forKey: Self.topSessionKey)
    }

    var pendingApprovalCount: Int {
        defaults.integer(forKey: Self.approvalCountKey)
    }

    var activeSessionCount: Int {
        defaults.integer(forKey: Self.activeCountKey)
    }

    var topSessionSummary: String? {
        defaults.string(forKey: Self.topSessionKey)
    }

    // MARK: - Auth State

    private static let isAuthenticatedKey = "is_authenticated"
    private static let serverUrlKey = "server_url"

    var isAuthenticated: Bool {
        get { defaults.bool(forKey: Self.isAuthenticatedKey) }
        set { defaults.set(newValue, forKey: Self.isAuthenticatedKey) }
    }

    var serverUrl: String? {
        get { defaults.string(forKey: Self.serverUrlKey) }
        set { defaults.set(newValue, forKey: Self.serverUrlKey) }
    }
}
