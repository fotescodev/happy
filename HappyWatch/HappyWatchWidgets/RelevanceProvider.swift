import WidgetKit

/// RelevanceKit scoring: higher relevance for pending approvals
struct HappyRelevanceProvider {
    private let storage = AppGroupStorage.shared

    /// Score: 1.0 for pending approvals, 0.5 for active sessions, 0.1 for idle
    func currentRelevance() -> TimelineEntryRelevance {
        let approvalCount = storage.pendingApprovalCount
        let activeCount = storage.activeSessionCount

        if approvalCount > 0 {
            return TimelineEntryRelevance(score: 1.0)
        } else if activeCount > 0 {
            return TimelineEntryRelevance(score: 0.5)
        } else {
            return TimelineEntryRelevance(score: 0.1)
        }
    }
}
