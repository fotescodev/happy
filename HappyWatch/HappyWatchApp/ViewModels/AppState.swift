import Foundation

/// Global @Observable state for the entire app
@MainActor @Observable
final class AppState {
    let auth = AuthService()
    let connectivity = ConnectivityService()
    private(set) var sync: SyncService!

    var selectedSession: WatchSession?
    var navigationPath: [NavigationDestination] = []

    enum NavigationDestination: Hashable {
        case sessionDetail(String)  // sessionId
        case approvalDetail(String, String)  // sessionId, requestId
        case approvalList
    }

    private let isDebugMode: Bool

    init() {
        isDebugMode = false
        sync = SyncService(connectivity: connectivity, auth: auth)
        connectivity.activate()

        // Set up notification handling
        NotificationService.shared.setup()
        Task { await requestNotificationPermission() }
    }

    #if DEBUG
    /// Create an AppState pre-loaded with mock data for simulator testing
    static func debug() -> AppState {
        let state = AppState(debugMode: true)
        return state
    }

    private init(debugMode: Bool) {
        isDebugMode = true
        sync = SyncService(connectivity: connectivity, auth: auth)
        auth.authenticateForDebug()
        sync.injectMockData(PreviewData.allSessions)
    }
    #endif

    // MARK: - Derived State

    var viewState: ViewState {
        ViewState.derive(
            isAuthenticated: auth.isAuthenticated,
            sessions: sync.sortedSessions,
            selectedSession: selectedSession,
            hasUrgentApprovals: sync.hasUrgentApprovals
        )
    }

    var sessions: [WatchSession] {
        sync.sortedSessions
    }

    var pendingApprovals: [(session: WatchSession, request: WatchAgentState.PermissionRequest)] {
        sync.allPendingRequests
    }

    // MARK: - Actions

    func selectSession(_ session: WatchSession) {
        selectedSession = session
    }

    func clearSelection() {
        selectedSession = nil
    }

    func approveRequest(sessionId: String, requestId: String) {
        sync.approveRequest(sessionId: sessionId, requestId: requestId)
    }

    func approveForSession(sessionId: String, requestId: String) {
        sync.approveRequest(sessionId: sessionId, requestId: requestId, decision: .approvedForSession)
    }

    func denyRequest(sessionId: String, requestId: String) {
        sync.denyRequest(sessionId: sessionId, requestId: requestId)
    }

    func abortRequest(sessionId: String, requestId: String) {
        sync.denyRequest(sessionId: sessionId, requestId: requestId, decision: .abort)
    }

    func refresh() async {
        if !connectivity.isReachable {
            await sync.refreshViaREST()
        } else {
            connectivity.requestSessionRefresh()
        }
    }

    // MARK: - Private

    private func requestNotificationPermission() async {
        let granted = await NotificationService.shared.requestAuthorization()
        if granted {
            NotificationService.shared.registerForRemoteNotifications()
        }
    }
}
