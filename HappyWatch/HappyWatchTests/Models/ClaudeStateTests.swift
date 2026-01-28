import Testing
@testable import HappyWatchApp

@Suite("ClaudeState Derivation")
struct ClaudeStateTests {

    @Test("Pending permissions → awaitingApproval (highest priority)")
    func awaitingApproval() {
        let session = MockData.sessionNeedsApproval
        #expect(session.claudeState == .awaitingApproval)
    }

    @Test("Thinking flag → thinking state")
    func thinking() {
        let session = MockData.sessionThinking
        #expect(session.claudeState == .thinking)
    }

    @Test("Controlled by user → paused")
    func paused() {
        var session = MockData.sessionWorking
        session.agentState = MockData.agentStatePaused
        #expect(session.claudeState == .paused)
    }

    @Test("Online with agent state and no special flags → working")
    func working() {
        let session = MockData.sessionWorking
        #expect(session.claudeState == .working)
    }

    @Test("Online with no agent state → idle")
    func idle() {
        let session = MockData.sessionIdle
        #expect(session.claudeState == .idle)
    }

    @Test("Not online, still active → offline")
    func offline() {
        let session = MockData.sessionOffline
        #expect(session.claudeState == .offline)
    }

    @Test("Not online, not active → completed")
    func completed() {
        let session = MockData.sessionCompleted
        #expect(session.claudeState == .completed)
    }

    @Test("Priority ordering: awaitingApproval > thinking > working > idle")
    func priorityOrdering() {
        #expect(ClaudeState.awaitingApproval > .thinking)
        #expect(ClaudeState.thinking > .working)
        #expect(ClaudeState.working > .idle)
        #expect(ClaudeState.idle > .offline)
        #expect(ClaudeState.offline > .completed)
    }

    @Test("Permission request takes priority over thinking")
    func permissionOverThinking() {
        var session = MockData.sessionThinking
        session.agentState = MockData.agentStateWithPermission
        #expect(session.claudeState == .awaitingApproval)
    }
}
