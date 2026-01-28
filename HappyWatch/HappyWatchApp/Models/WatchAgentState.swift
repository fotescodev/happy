import Foundation

/// Mirrors storageTypes.ts AgentStateSchema
struct WatchAgentState: Codable, Sendable, Equatable {
    var controlledByUser: Bool?
    var requests: [String: PermissionRequest]?
    var completedRequests: [String: CompletedRequest]?

    struct PermissionRequest: Codable, Sendable, Equatable, Identifiable {
        let id: String
        let tool: String
        let arguments: AnyCodable
        var createdAt: TimeInterval?

        init(id: String, tool: String, arguments: AnyCodable, createdAt: TimeInterval? = nil) {
            self.id = id
            self.tool = tool
            self.arguments = arguments
            self.createdAt = createdAt
        }

        enum CodingKeys: String, CodingKey {
            case tool, arguments, createdAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // The id comes from the dictionary key, not from the JSON itself
            self.id = ""
            self.tool = try container.decode(String.self, forKey: .tool)
            self.arguments = try container.decodeIfPresent(AnyCodable.self, forKey: .arguments) ?? AnyCodable(nil)
            self.createdAt = try container.decodeIfPresent(TimeInterval.self, forKey: .createdAt)
        }
    }

    struct CompletedRequest: Codable, Sendable, Equatable {
        let tool: String
        let arguments: AnyCodable
        var createdAt: TimeInterval?
        var completedAt: TimeInterval?
        let status: RequestStatus
        var reason: String?
        var mode: String?
        var allowedTools: [String]?
        var decision: PermissionDecision?
    }

    /// All pending permission requests, sorted by creation time
    var pendingRequests: [PermissionRequest] {
        guard let requests else { return [] }
        return requests.map { key, value in
            PermissionRequest(id: key, tool: value.tool, arguments: value.arguments, createdAt: value.createdAt)
        }.sorted { ($0.createdAt ?? 0) < ($1.createdAt ?? 0) }
    }

    /// Whether there are any pending permission requests
    var hasPermissionRequests: Bool {
        guard let requests else { return false }
        return !requests.isEmpty
    }
}

/// Type-erased Codable wrapper for JSON `arguments` fields
struct AnyCodable: Codable, @unchecked Sendable, Equatable {
    let value: Any?

    init(_ value: Any?) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues(\.value)
        } else if let arr = try? container.decode([AnyCodable].self) {
            value = arr.map(\.value)
        } else if let str = try? container.decode(String.self) {
            value = str
        } else if let num = try? container.decode(Double.self) {
            value = num
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value == nil {
            try container.encodeNil()
        } else if let str = value as? String {
            try container.encode(str)
        } else if let num = value as? Double {
            try container.encode(num)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let dict = value as? [String: Any?] {
            try container.encode(dict.mapValues { AnyCodable($0) })
        } else if let arr = value as? [Any?] {
            try container.encode(arr.map { AnyCodable($0) })
        } else {
            try container.encodeNil()
        }
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Simple equality: both nil, or both encode to same JSON
        if lhs.value == nil && rhs.value == nil { return true }
        guard let lData = try? JSONEncoder().encode(lhs),
              let rData = try? JSONEncoder().encode(rhs) else { return false }
        return lData == rData
    }

    /// Attempt to extract as a dictionary of strings (common for tool arguments)
    var stringDictionary: [String: String]? {
        value as? [String: String]
    }

    /// Attempt to extract as a dictionary of any values
    var dictionary: [String: Any?]? {
        value as? [String: Any?]
    }

    /// Pretty-printed JSON string for display
    var prettyJSON: String {
        guard let data = try? JSONEncoder.prettyPrinting.encode(self),
              let str = String(data: data, encoding: .utf8) else {
            return String(describing: value ?? "null")
        }
        return str
    }
}

private extension JSONEncoder {
    static let prettyPrinting: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}
