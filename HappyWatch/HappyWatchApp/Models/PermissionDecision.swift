import Foundation

/// Matches the decision enum from ops.ts SessionPermissionRequest
enum PermissionDecision: String, Codable, Sendable {
    case approved
    case approvedForSession = "approved_for_session"
    case denied
    case abort
}

/// Matches the completed request status from AgentStateSchema
enum RequestStatus: String, Codable, Sendable {
    case canceled
    case denied
    case approved
}
