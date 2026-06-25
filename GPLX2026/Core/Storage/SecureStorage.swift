import Foundation
import CryptoKit

/// Encrypts sensitive data before storing in UserDefaults.
/// Key is generated once and stored in Keychain.
struct SecureStorage {
    private static let keychainService = "com.gplx2026.secureStorage"
    private static let keychainAccount = "encryptionKey"

    static func save<T: Encodable>(_ value: T, forKey key: String, defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        guard let encrypted = try? encrypt(data) else {
            // Fallback to plain storage if encryption fails
            defaults.set(data, forKey: key)
            return
        }
        defaults.set(encrypted, forKey: key)
    }

    static func load<T: Decodable>(_ type: T.Type, forKey key: String, defaults: UserDefaults) -> T? {
        guard let stored = defaults.data(forKey: key) else { return nil }
        // Try decryption first, fall back to plain decode (migration)
        let data = (try? decrypt(stored)) ?? stored
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Encryption

    private static func encrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.sealFailed
        }
        return combined
    }

    private static func decrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Key management (Keychain)

    private static func getOrCreateKey() throws -> SymmetricKey {
        if let existing = loadKeyFromKeychain() { return existing }
        let newKey = SymmetricKey(size: .bits256)
        try saveKeyToKeychain(newKey)
        // `saveKeyToKeychain` tolerates errSecDuplicateItem — a concurrent caller
        // may have created the key first. In that race the persisted key is NOT
        // `newKey`, so always re-read the canonical key from the Keychain and use
        // it; otherwise we'd encrypt with a key that was never stored and later
        // fail to decrypt.
        if let stored = loadKeyFromKeychain() { return stored }
        return newKey
    }

    private static func loadKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return SymmetricKey(data: data)
    }

    private static func saveKeyToKeychain(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw CryptoError.keychainSaveFailed
        }
    }

    enum CryptoError: Error {
        case sealFailed
        case keychainSaveFailed
    }
}
