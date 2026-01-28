import Foundation
import Testing
@testable import HappyWatchApp

@Suite("SyncService")
struct SyncServiceTests {

    @Test("Sessions needing approval filters correctly")
    func sessionsNeedingApproval() {
        // Create sync service with mock data via direct property testing
        let sessions = MockData.allSessions
        let needingApproval = sessions.filter(\.hasPendingApprovals)

        #expect(needingApproval.count == 1)
        #expect(needingApproval.first?.id == "session-003")
    }

    @Test("All pending requests collects across sessions")
    func allPendingRequests() {
        let sessions = MockData.allSessions
        let allPending = sessions.flatMap { session in
            session.pendingRequests.map { (session: session, request: $0) }
        }

        #expect(allPending.count == 1)
        #expect(allPending.first?.request.tool == "Bash")
    }

    @Test("Sorted sessions prioritizes by claude state")
    func sortedSessions() {
        let sessions = MockData.allSessions
        let sorted = sessions
            .filter(\.active)
            .sorted { $0.claudeState > $1.claudeState }

        // awaitingApproval should be first
        #expect(sorted.first?.claudeState == .awaitingApproval)
    }

    @Test("Session with multiple permission requests lists all")
    func multiplePermissions() {
        var session = MockData.sessionWorking
        session.agentState = MockData.agentStateMultiplePermissions

        let requests = session.pendingRequests
        #expect(requests.count == 2)
        // Should be sorted by createdAt
        #expect(requests.first?.tool == "Bash")
        #expect(requests.last?.tool == "Write")
    }

    @Test("WatchSession Codable round-trip")
    func sessionCodableRoundTrip() throws {
        let original = MockData.sessionWorking
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WatchSession.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.seq == original.seq)
        #expect(decoded.active == original.active)
        #expect(decoded.metadata?.host == original.metadata?.host)
        #expect(decoded.metadata?.displayName == original.metadata?.displayName)
    }

    @Test("Presence decoding: online string")
    func presenceOnline() throws {
        let json = #""online""#.data(using: .utf8)!
        let presence = try JSONDecoder().decode(WatchSession.Presence.self, from: json)
        #expect(presence.isOnline)
    }

    @Test("Presence decoding: timestamp number")
    func presenceTimestamp() throws {
        let json = "1706400000".data(using: .utf8)!
        let presence = try JSONDecoder().decode(WatchSession.Presence.self, from: json)
        #expect(!presence.isOnline)
    }
}
