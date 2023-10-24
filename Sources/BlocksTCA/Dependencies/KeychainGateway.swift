import Blocks
import ComposableArchitecture
import Foundation

/**
 A wrapper for a keychain item main properties.
 */
public struct KeychainItem {
    let itemClass: ItemClass?
    let account: String
    let secret: Data?
    let label: String?
    let rawProps: [String: Any]?

    enum ItemClass {
        case genericPassword
        case internetPassword
        case certificate
        case key
        case identity

        init?(classCFString: CFString) {
            switch classCFString {
            case kSecClassGenericPassword:
                self = .genericPassword
            case kSecClassInternetPassword:
                self = .internetPassword
            case kSecClassCertificate:
                self = .certificate
            case kSecClassKey:
                self = .key
            case kSecClassIdentity:
                self = .identity
            default:
                return nil
            }
        }
    }
}

extension KeychainItem: Equatable {
    public static func == (lhs: KeychainItem, rhs: KeychainItem) -> Bool {
        lhs.account == rhs.account
    }
}

extension KeychainItem.ItemClass: CustomStringConvertible {
    var description: String {
        switch self {
        case .genericPassword: "Generic Password"
        case .internetPassword: "Internet Password"
        case .certificate: "Certificate"
        case .key: "Key"
        case .identity: "Identity"
        }
    }
}

/**
 A protocol that defines a set of methods for interacting with the iOS Keychain.
 */
protocol KeychainGateway {
    func listItems() throws -> [KeychainItem]

    func addItem(account: String, secret: Data) throws
}

struct LiveKeychainGateway: KeychainGateway {
    func listItems() throws -> [KeychainItem] {
        let allSecItemClasses: [CFString] = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        var result: [KeychainItem] = []
        try allSecItemClasses.forEach { secItemClass in
            // Create a Search Query
            let query: [String: Any] = [
                kSecClass as String: secItemClass,
                kSecReturnAttributes as String: true,
                kSecMatchLimit as String: kSecMatchLimitAll
            ]

            // Initiate the Search
            var items: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &items)

            guard status != errSecItemNotFound else {
                return
            }

            guard status == errSecSuccess else {
                throw KeychainError.unhandledError(status: status)
            }

            // Extract the Result
            guard let existingItems = items as? [[String: Any]] else {
                throw KeychainError.unexpectedData
            }

            try existingItems.forEach { existingItem in
                guard let secretData = existingItem[kSecValueData as String] as? Data?,
                      let account = existingItem[kSecAttrAccount as String] as? String,
                      let label = existingItem[kSecAttrLabel as String] as? String?
                else {
                    throw KeychainError.unexpectedData
                }

                result.append(
                    KeychainItem(
                        itemClass: KeychainItem.ItemClass(classCFString: secItemClass),
                        account: account,
                        secret: secretData,
                        label: label,
                        rawProps: existingItem
                    )
                )
            }
        }

        return result
    }

    func addItem(account: String, secret: Data) throws {
        // Create an Add Query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: secret
        ]

        // Add the Item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

// - MARK: TCA Dependency

enum KeychainGatewayKey: DependencyKey {
    static let liveValue: KeychainGateway = LiveKeychainGateway()
}

extension DependencyValues {
    var keychainGateway: KeychainGateway {
        get { self[KeychainGatewayKey.self] }
        set { self[KeychainGatewayKey.self] = newValue }
    }
}
