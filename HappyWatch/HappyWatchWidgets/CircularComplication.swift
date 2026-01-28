import SwiftUI
import WidgetKit

/// Circular complication: session count gauge with brand color fill
struct CircularComplication: Widget {
    let kind = "CircularComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SessionTimelineProvider()) { entry in
            CircularComplicationView(entry: entry)
        }
        .configurationDisplayName("Session Count")
        .description("Active session count gauge")
        .supportedFamilies([.accessoryCircular])
    }
}

struct CircularComplicationView: View {
    let entry: SessionEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            Gauge(value: Double(min(entry.activeCount, 10)), in: 0...10) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
            } currentValueLabel: {
                Text("\(entry.activeCount)")
                    .font(.system(size: 20, weight: .bold))
            }
            .gaugeStyle(.accessoryCircular)
            .tint(entry.approvalCount > 0 ? .orange : .accentColor)
        }
    }
}

#Preview(as: .accessoryCircular) {
    CircularComplication()
} timeline: {
    SessionEntry.placeholder
    SessionEntry.empty
}
