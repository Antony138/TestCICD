//
//  Configuration.swift
//  EVP4
//
//  Created by Stone Zhang on 8/29/22.
//

import Foundation

class Configuration {
    enum Key: String {
        case hereSDKCredentialID = "HERE_SDK_CREDENTIAL_ID"
        case hereSDKCredentialSecret = "HERE_SDK_CREDENTIAL_SECRET"
    }

    func string(for key: Key) -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else {
            fatalError("[Configuration] - Missing key `\(key.rawValue)`")
        }
        guard let string = object as? String else {
            fatalError("[Configuration] - Invalid value format `\(object)`")
        }
        return string
    }

}
