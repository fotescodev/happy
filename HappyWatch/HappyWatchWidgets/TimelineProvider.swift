import WidgetKit

/// Shared data for all complications, read from AppGroup storage
struct SessionEntry: TimelineEntry {
    let date: Date
    let activeCount: Int
    let approvalCount: Int
    let topSessionName: String?
    let topSessionState: String

    static let placeholder = SessionEntry(
        date: .now,
        activeCount: 2,
        approvalCount: 1,
        topSessionName: "my-project",
        topSessionState: "Working"
    )

    static let empty = SessionEntry(
        date: .now,
        activeCount: 0,
        approvalCount: 0,
        topSessionName: nil,
        topSessionState: "Idle"
    )
}

struct SessionTimelineProvider: TimelineProvider {
    private let storage = AppGroupStorage.shared

    func placeholder(in context: Context) -> SessionEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SessionEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SessionEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> SessionEntry {
        let sessions = storage.loadSessions()
        let active = sessions.filter(\.active)
        let approvals = sessions.flatMap(\.pendingRequests).count
        let top = active.sorted { ($0.claudeState.rawValue) > ($1.claudeState.rawValue) }.first

        return SessionEntry(
            date: .now,
            activeCount: active.count,
            approvalCount: approvals,
            topSessionName: top?.displayName,
            topSessionState: top?.claudeState.label ?? "Idle"
        )
    }
}
