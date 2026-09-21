//
//  KeychainItem.swift
//  Pepitas
//
//  Created by Michael Scott on 21/09/2026.
//

import Foundation
import Security

/// A single generic-password entry in the keychain, identified by a service and account pair.
nonisolated struct KeychainItem {
    let service: String
    let account: String

    /// The stored secret, or `nil` when no entry exists.
    func read() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Stores `secret`, replacing any existing entry. An empty secret removes the entry instead.
    @discardableResult
    func write(_ secret: String) -> Bool {
        guard !secret.isEmpty else { return delete() }

        let data = Data(secret.utf8)
        let status = SecItemUpdate(baseQuery as CFDictionary,
                                   [kSecValueData as String: data] as CFDictionary)
        guard status == errSecItemNotFound else { return status == errSecSuccess }

        // No entry yet, so create one.
        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// Removes the entry. Succeeds when there was nothing to remove.
    @discardableResult
    func delete() -> Bool {
        let status = SecItemDelete(baseQuery as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
