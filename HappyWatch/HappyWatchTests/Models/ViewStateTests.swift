import Testing
@testable import HappyWatchApp

@Suite("ViewState Derivation")
struct ViewStateTests {

    @Test("Not authenticated → onboarding")
    func onboarding() {
        let state = ViewState.derive(
            isAuthenticated: false,
            sessions: [],
            selectedSession: nil,
            hasUrgentApprovals: false
        )
        #expect(state == .onboarding)
    }

    @Test("Authenticated with no sessions → noSessions")
    func noSessions() {
        let state = ViewState.derive(
            isAuthenticated: true,
            sessions: [],
            selectedSession: nil,
            hasUrgentApprovals: false
        )
        #expect(state == .noSessions)
    }

    @Test("Authenticated with sessions → sessionList")
    func sessionList() {
        let state = ViewState.derive(
            isAuthenticated: true,
            sessions: [MockData.sessionWorking],
            selectedSession: nil,
            hasUrgentApprovals: false
        )
        #expect(state == .sessionList)
    }

    @Test("Selected session → sessionDetail")
    func sessionDetail() {
        let session = MockData.sessionWorking
        let state = ViewState.derive(
            isAuthenticated: true,
            sessions: [session],
            selectedSession: session,
            hasUrgentApprovals: false
        )
        #expect(state == .sessionDetail(session))
    }

    @Test("Urgent approvals take priority over selected session")
    func approvalPriority() {
        let state = ViewState.derive(
            isAuthenticated: true,
            sessions: [MockData.sessionNeedsApproval],
            selectedSession: MockData.sessionWorking,
            hasUrgentApprovals: true
        )
        #expect(state == .approvalRequired)
    }

    @Test("Not authenticated always → onboarding regardless of other state")
    func authAlwaysFirst() {
        let state = ViewState.derive(
            isAuthenticated: false,
            sessions: [MockData.sessionNeedsApproval],
            selectedSession: MockData.sessionWorking,
            hasUrgentApprovals: true
        )
        #expect(state == .onboarding)
    }
}
