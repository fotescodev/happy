import SwiftUI
import WidgetKit

/// watchOS 26 Control API: quick approve from Control Center
struct ApproveControl: ControlWidget {
    let kind = "ApproveControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: ApproveIntent()) {
                Label {
                    Text("\(AppGroupStorage.shared.pendingApprovalCount) Pending")
                } icon: {
                    Image(systemName: AppGroupStorage.shared.pendingApprovalCount > 0
                          ? "hand.raised.fill"
                          : "checkmark.seal.fill")
                }
            }
        }
        .displayName("Quick Approve")
        .description("Approve the most recent permission request")
    }
}

/// AppIntent for the control widget's approve action
import AppIntents

struct ApproveIntent: AppIntent {
    static var title: LocalizedStringResource = "Approve Permission"
    static var description: IntentDescription = "Approve the most recent pending permission request"

    func perform() async throws -> some IntentResult {
        // Open the app to the approval screen
        // The actual approval happens in the app UI
        return .result()
    }

    static var openAppWhenRun: Bool { true }
}
