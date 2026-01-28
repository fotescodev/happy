import SwiftUI

/// 8-value enum representing the derived state of a Claude session.
/// Priority-ordered: higher rawValue = higher priority for display.
enum ClaudeState: Int, Comparable, Sendable, CaseIterable {
    case completed = 0
    case offline = 1
    case idle = 2
    case paused = 3
    case working = 4
    case thinking = 5
    case error = 6
    case awaitingApproval = 7

    static func < (lhs: ClaudeState, rhs: ClaudeState) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Derive state from a WatchSession's properties
    static func derive(from session: WatchSession) -> ClaudeState {
        // Highest priority: pending permission requests
        if session.agentState?.hasPermissionRequests == true {
            return .awaitingApproval
        }

        // Thinking state (ephemeral activity indicator)
        if session.thinking {
            return .thinking
        }

        // Controlled by user means paused/waiting for input
        if session.agentState?.controlledByUser == true {
            return .paused
        }

        // Check presence
        if !session.presence.isOnline {
            if !session.active {
                return .completed
            }
            return .offline
        }

        // Online but no activity → idle or working
        // If we have agent state but no requests and not controlled by user, it's working
        if session.agentState != nil {
            return .working
        }

        return .idle
    }

    var label: String {
        switch self {
        case .completed: "Completed"
        case .offline: "Offline"
        case .idle: "Idle"
        case .paused: "Paused"
        case .working: "Working"
        case .thinking: "Thinking"
        case .error: "Error"
        case .awaitingApproval: "Needs Approval"
        }
    }

    var color: Color {
        switch self {
        case .completed: HappyColors.idle
        case .offline: HappyColors.idle
        case .idle: HappyColors.idle
        case .paused: HappyColors.warning
        case .working: HappyColors.brand
        case .thinking: HappyColors.context
        case .error: HappyColors.danger
        case .awaitingApproval: HappyColors.question
        }
    }

    var systemImage: String {
        switch self {
        case .completed: "checkmark.circle.fill"
        case .offline: "wifi.slash"
        case .idle: "moon.fill"
        case .paused: "pause.circle.fill"
        case .working: "gearshape.2.fill"
        case .thinking: "brain.head.profile.fill"
        case .error: "exclamationmark.triangle.fill"
        case .awaitingApproval: "hand.raised.fill"
        }
    }
}
