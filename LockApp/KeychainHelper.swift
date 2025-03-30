import Security
import Foundation

class KeychainHelper {
    static let standard = KeychainHelper()

    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ] as CFDictionary
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess { print("Keychain save error: \(status)") }
    }

    func read(service: String, account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        return status == errSecSuccess ? item as? Data : nil
    }
}
