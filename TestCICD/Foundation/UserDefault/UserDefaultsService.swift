//
//  UserDefaultsService.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/25.
//

import Foundation
import heresdk

enum AppKeys: String {
    case recentPlaces
}

protocol UserDefaultsServiceType: AnyObject {
    // Same function name as Apple API, avoid re-implement
    func set(_ value: Any?, forKey defaultName: String)

    func array(forKey defaultName: String) -> [Any]?
}

extension UserDefaultsServiceType {
    var recentPlaces: [Place] {
        get {
            (array(forKey: AppKeys.recentPlaces.rawValue) as? [String] ?? [])
                .map { try? Place.deserialize(serializedPlace: $0) }
                .compactMap { $0 }
        }

        set {
            // Array(Set(value)): avoid duplication
            set(Array(Set(newValue.map { $0.serializeCompact() })), forKey: AppKeys.recentPlaces.rawValue)
        }
    }
}

extension UserDefaults: UserDefaultsServiceType {
    static var instance: UserDefaults {
        UserDefaults(suiteName: "group.com.drivemode.EVP4") ?? UserDefaults.standard
    }
}
