import Foundation
import CryptoKit

/// Bridge for decrypting session data when in standalone (cellular) mode.
/// iPhone handles all decryption normally; this is only for REST fallback.
final class EncryptionBridge: Sendable {

    /// AES-256-GCM decryption (DataKey variant)
    /// Format: nonce (12 bytes) + ciphertext + tag (16 bytes)
    static func decryptAES256GCM(data: Data, key: Data) throws -> Data {
        guard data.count > 28 else { throw EncryptionError.dataTooShort }

        let nonce = data[0..<12]
        let ciphertextAndTag = data[12...]

        let sealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: nonce),
            ciphertext: ciphertextAndTag.dropLast(16),
            tag: ciphertextAndTag.suffix(16)
        )
        let symmetricKey = SymmetricKey(data: key)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }

    /// AES-256-GCM encryption
    static func encryptAES256GCM(data: Data, key: Data) throws -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)

        // Format: nonce + ciphertext + tag
        var result = Data()
        result.append(contentsOf: sealedBox.nonce)
        result.append(sealedBox.ciphertext)
        result.append(sealedBox.tag)
        return result
    }

    /// Decrypt a base64-encoded encrypted string to JSON
    static func decryptJSON<T: Decodable>(
        _ encrypted: String,
        key: Data,
        as type: T.Type
    ) throws -> T {
        guard let encryptedData = Data(base64Encoded: encrypted) else {
            throw EncryptionError.invalidBase64
        }
        let decryptedData = try decryptAES256GCM(data: encryptedData, key: key)
        return try JSONDecoder().decode(type, from: decryptedData)
    }

    /// Encrypt a JSON value to base64-encoded encrypted string
    static func encryptJSON<T: Encodable>(_ value: T, key: Data) throws -> String {
        let jsonData = try JSONEncoder().encode(value)
        let encrypted = try encryptAES256GCM(data: jsonData, key: key)
        return encrypted.base64EncodedString()
    }

    /// HMAC-SHA512 for key derivation (matches deriveKey.ts)
    static func hmacSHA512(key: Data, data: Data) -> Data {
        let hmac = HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: key))
        return Data(hmac)
    }

    /// Derive a key following Happy's key tree derivation
    /// masterSecret → deriveKey(masterSecret, usage, path)
    static func deriveKey(master: Data, usage: String, path: [String]) throws -> Data {
        guard let usageData = (usage + " Master Seed").data(using: .utf8) else {
            throw EncryptionError.invalidInput
        }

        // Root derivation: HMAC-SHA512(usage + " Master Seed", seed)
        let rootResult = hmacSHA512(key: usageData, data: master)
        var currentKey = rootResult[0..<32]
        var chainCode = rootResult[32..<64]

        // Child derivation for each path component
        for index in path {
            guard let indexData = index.data(using: .utf8) else {
                throw EncryptionError.invalidInput
            }
            var childData = Data([0x0])
            childData.append(indexData)
            let childResult = hmacSHA512(key: chainCode, data: childData)
            currentKey = childResult[0..<32]
            chainCode = childResult[32..<64]
        }

        return Data(currentKey)
    }
}

enum EncryptionError: Error, LocalizedError {
    case dataTooShort
    case invalidBase64
    case invalidInput
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .dataTooShort: "Encrypted data too short"
        case .invalidBase64: "Invalid base64 encoding"
        case .invalidInput: "Invalid input data"
        case .decryptionFailed: "Decryption failed"
        }
    }
}
