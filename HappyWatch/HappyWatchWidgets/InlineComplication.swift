import SwiftUI
import WidgetKit

/// Inline complication: "2 active · 1 needs approval"
struct InlineComplication: Widget {
    let kind = "InlineComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SessionTimelineProvider()) { entry in
            InlineComplicationView(entry: entry)
        }
        .configurationDisplayName("Session Summary")
        .description("Inline session count and status")
        .supportedFamilies([.accessoryInline])
    }
}

struct InlineComplicationView: View {
    let entry: SessionEntry

    var body: some View {
        if entry.approvalCount > 0 {
            Label("\(entry.activeCount) active · \(entry.approvalCount) approval", systemImage: "hand.raised.fill")
        } else if entry.activeCount > 0 {
            Label("\(entry.activeCount) active", systemImage: "chevron.left.forwardslash.chevron.right")
        } else {
            Label("No sessions", systemImage: "moon.fill")
        }
    }
}

#Preview(as: .accessoryInline) {
    InlineComplication()
} timeline: {
    SessionEntry.placeholder
    SessionEntry.empty
}
