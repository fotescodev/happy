import SwiftUI

/// Row: project name + ClaudeState badge + relative time
struct SessionRowView: View {
    let session: WatchSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.displayName)
                    .font(HappyTypography.body)
                    .lineLimit(1)

                Spacer()

                StatusBadge(state: session.claudeState, compact: true)
            }

            HStack {
                if let host = session.metadata?.host {
                    Text(host)
                        .font(HappyTypography.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(relativeTime(from: session.activeAt))
                    .font(HappyTypography.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }

    private func relativeTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let interval = Date().timeIntervalSince(date)

        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}
