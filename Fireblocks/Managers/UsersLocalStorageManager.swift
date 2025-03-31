//
//  UsersLocalStorageManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 08/08/2023.
//

import Foundation
import FirebaseAuth

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class Preference<T> {
    let group: String
    let key: String
    lazy var groupAlias: String = {
        "\(key)_\(group)"
    }()

    let defaultValue: T?

    func value() -> T? {
        return defaultValue
    }

    func set(_ value: T) {}

    init(group: String?, key: String, defaultValue: T? = nil) {
        self.group = group ?? ""
        self.key = key
        self.defaultValue = defaultValue
    }
}

final class CodablePreference<T: Codable>: Preference<T> {
    let defaults: UserDefaults

    override func value() -> T? {
        return T.fromData(defaults.data(forKey: groupAlias)) ?? defaultValue
    }

    override func set(_ value: T) {
        let data = value.toData()
        if let data {
            defaults.set(data, forKey: groupAlias)
        }
    }


    init(defaults: UserDefaults, group: String?, key: String, defaultValue: T? = nil) {
        self.defaults = defaults
        super.init(group: group, key: key, defaultValue: defaultValue)
    }
}

class UsersLocalStorageManager: ObservableObject {
    let defaults = UserDefaults.standard

    static let shared = UsersLocalStorageManager()
    private init() {
    }
    
    func lastLoggedInEmail() -> String? {
        return defaults.string(forKey: "lastLoggedInEmail")
    }

    func setLastLoggedInEmail(email: String) {
        defaults.set(email, forKey: "lastLoggedInEmail")
    }

    func lastDeviceId(email: String) -> String? {
        return defaults.string(forKey: "\(email)-deviceId")
    }

    func setLastDeviceId(deviceId: String, email: String) {
        defaults.set(deviceId, forKey: "\(email)-deviceId")
    }
    
    func removeLastDeviceId(email: String) {
        defaults.removeObject(forKey: "\(email)-deviceId")
    }


    func setAddDeviceTimer() {
        defaults.set(Date().timeIntervalSince1970, forKey: "addDeviceStartTimer")
    }

    func getAddDeviceTimer() -> Double? {
        defaults.double(forKey: "addDeviceStartTimer")
    }
    
    func setAuthProvider(value: String) {
        defaults.set(value, forKey: "authProvider")
    }

    func getAuthProvider() -> String? {
        defaults.string(forKey: "authProvider")
    }
    
    func resetAuthProvider() {
        defaults.removeObject(forKey: "authProvider")
    }
    
    lazy var approvedTransactions: CodablePreference<[String]> = {
        CodablePreference<[String]>(defaults: defaults, group: "", key: "approvedTransactions", defaultValue: [])
    }()

    private lazy var assetsAddresses: CodablePreference<[Int: [String: [AddressDetails]]]> = {
        CodablePreference<[Int: [String: [AddressDetails]]]>(defaults: defaults, group: Auth.auth().currentUser?.email, key: "assetsAddresses", defaultValue: [:])
    }()
    
    func getAddressDetails(accountId: Int, assetId: String) -> [AddressDetails]? {
        return assetsAddresses.value()?[accountId]?[assetId]
    }
    
    func setAddressDetails(accountId: Int, assetId: String, addressDetails: [AddressDetails]) {
        var dictionary = assetsAddresses.value() ?? [:]
        if dictionary[accountId] == nil {
            dictionary[accountId] = [:]
        }
        dictionary[accountId]?[assetId] = addressDetails
        assetsAddresses.set(dictionary)
    }
}
