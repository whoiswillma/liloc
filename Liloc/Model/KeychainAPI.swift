//
//  KeychainAPI.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Foundation

enum KeychainError: Error {

    case tokenDataError
    case unexpectedTokenFormat
    case oserror(_ status: OSStatus)

    var localizedDescription: String {
        switch self {
        case .tokenDataError:
            return "The token could not be converted to utf8"

        case .unexpectedTokenFormat:
            return "The token is missing or could not be converted to a string"

        case .oserror(let status):
            return SecCopyErrorMessageString(status, nil) as String? ?? ""
        }
    }
    
}

enum KeychainAPI {

    static let todoist = KeychainTokenAPI(server: "https://todoist.com")
    static let toggl = KeychainAccountPasswordAPI(server: "https://toggl.com")

}

protocol KeychainAccessAPI {

    associatedtype Contents

    func add(_ data: Contents) throws
    func fetch() throws -> Contents?
    func update(_ data: Contents) throws
    func delete() throws
    func set(_ data: Contents) throws

}

extension KeychainAccessAPI {

    func set(_ data: Contents) throws {
        if try fetch() == nil {
            try add(data)
        } else {
            try update(data)
        }
    }

}

struct KeychainTokenAPI: KeychainAccessAPI {

    let server: String

    func add(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.tokenDataError
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.oserror(status)
        }
    }

    func fetch() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { throw KeychainError.oserror(status) }

        guard let data = item as? Data,
            let token = String(data: data, encoding: .utf8) else
        {
            throw KeychainError.unexpectedTokenFormat
        }

        return token
    }

    func update(_ token: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]

        guard let data = token.data(using: .utf8) else {
            throw KeychainError.tokenDataError
        }

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        guard status != errSecItemNotFound else { return try add(token) }
        guard status == errSecSuccess else { throw KeychainError.oserror(status) }
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.oserror(status)
        }
    }

}

struct KeychainAccountPasswordAPI: KeychainAccessAPI {

    let server: String

    func add(_ accountPassword: (account: String, password: String)) throws {
        let (account: account, password: password) = accountPassword

        guard let data = password.data(using: .utf8) else {
            throw KeychainError.tokenDataError
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.oserror(status)
        }
    }

    func fetch() throws -> (account: String, password: String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { throw KeychainError.oserror(status) }

        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let account = existingItem[kSecAttrAccount as String] as? String else
        {
            throw KeychainError.unexpectedTokenFormat
        }

        return (account: account, password: password)
    }

    func update(_ accountPassword: (account: String, password: String)) throws {
        let (account: account, password: password) = accountPassword

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]

        guard let data = password.data(using: .utf8) else {
            throw KeychainError.tokenDataError
        }

        let attributes: [String: Any] = [
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        guard status != errSecItemNotFound else {
            return try add((account: account, password: password))
        }
        guard status == errSecSuccess else { throw KeychainError.oserror(status) }
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.oserror(status)
        }
    }

}
