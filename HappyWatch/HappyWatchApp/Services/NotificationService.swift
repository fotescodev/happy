import Foundation
import UserNotifications
import WatchKit

/// Handles APNs registration and actionable notifications for permission requests
final class NotificationService: NSObject, Sendable {
    static let shared = NotificationService()

    static let permissionCategory = "PERMISSION_REQUEST"
    static let approveAction = "APPROVE_ACTION"
    static let denyAction = "DENY_ACTION"

    private override init() {
        super.init()
    }

    func setup() {
        let center = UNUserNotificationCenter.current()

        // Define actionable notification category
        let approveAction = UNNotificationAction(
            identifier: Self.approveAction,
            title: "Approve",
            options: [.authenticationRequired]
        )
        let denyAction = UNNotificationAction(
            identifier: Self.denyAction,
            title: "Deny",
            options: [.authenticationRequired, .destructive]
        )
        let category = UNNotificationCategory(
            identifier: Self.permissionCategory,
            actions: [approveAction, denyAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            return false
        }
    }

    func registerForRemoteNotifications() {
        WKApplication.shared().registerForRemoteNotifications()
    }

    /// Schedule a local notification for a permission request
    func showPermissionNotification(sessionName: String, tool: String, requestId: String, sessionId: String) {
        let content = UNMutableNotificationContent()
        content.title = sessionName
        content.body = "\(tool) needs approval"
        content.categoryIdentifier = Self.permissionCategory
        content.userInfo = [
            "sessionId": sessionId,
            "requestId": requestId,
        ]
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "permission-\(requestId)",
            content: content,
            trigger: nil  // Deliver immediately
        )
        UNUserNotificationCenter.current().add(request)
    }
}
