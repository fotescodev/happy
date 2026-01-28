import Foundation

/// Mirrors storageTypes.ts MetadataSchema
struct WatchMetadata: Codable, Sendable, Equatable {
    let path: String
    let host: String
    var version: String?
    var name: String?
    var os: String?
    var summary: Summary?
    var machineId: String?
    var claudeSessionId: String?
    var tools: [String]?
    var slashCommands: [String]?
    var homeDir: String?
    var happyHomeDir: String?
    var hostPid: Int?
    var flavor: String?

    struct Summary: Codable, Sendable, Equatable {
        let text: String
        let updatedAt: TimeInterval
    }

    /// Display name: uses name if available, otherwise last path component
    var displayName: String {
        if let name, !name.isEmpty { return name }
        return (path as NSString).lastPathComponent
    }
}
