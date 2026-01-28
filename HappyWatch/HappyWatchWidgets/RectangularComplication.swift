import SwiftUI
import WidgetKit

/// Rectangular complication: session name + one-line status
struct RectangularComplication: Widget {
    let kind = "RectangularComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SessionTimelineProvider()) { entry in
            RectangularComplicationView(entry: entry)
        }
        .configurationDisplayName("Session Status")
        .description("Top session name and status")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct RectangularComplicationView: View {
    let entry: SessionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.caption2)
                Text("Happy")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }

            if let name = entry.topSessionName {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                Text(entry.topSessionState)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No sessions")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if entry.approvalCount > 0 {
                Text("\(entry.approvalCount) needs approval")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(as: .accessoryRectangular) {
    RectangularComplication()
} timeline: {
    SessionEntry.placeholder
    SessionEntry.empty
}
