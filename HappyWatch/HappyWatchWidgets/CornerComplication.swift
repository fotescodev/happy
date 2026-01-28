import SwiftUI
import WidgetKit

/// Corner complication: warning icon when approval needed
struct CornerComplication: Widget {
    let kind = "CornerComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SessionTimelineProvider()) { entry in
            CornerComplicationView(entry: entry)
        }
        .configurationDisplayName("Session Alert")
        .description("Icon with approval alert")
        .supportedFamilies([.accessoryCorner])
    }
}

struct CornerComplicationView: View {
    let entry: SessionEntry

    var body: some View {
        ZStack {
            if entry.approvalCount > 0 {
                Image(systemName: "hand.raised.fill")
                    .font(.title3)
                    .widgetLabel {
                        Text("\(entry.approvalCount)")
                    }
            } else if entry.activeCount > 0 {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.title3)
                    .widgetLabel {
                        Text("\(entry.activeCount) active")
                    }
            } else {
                Image(systemName: "moon.fill")
                    .font(.title3)
                    .widgetLabel {
                        Text("Idle")
                    }
            }
        }
    }
}

#Preview(as: .accessoryCorner) {
    CornerComplication()
} timeline: {
    SessionEntry.placeholder
    SessionEntry.empty
}
