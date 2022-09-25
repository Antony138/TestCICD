//
//  BluetoothError.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/03.
//

import Foundation
import CoreBluetooth

enum BluetoothError: Error, CustomStringConvertible {
    case noAdvertisingCharacteristic
    case addingServiceFailed(CBMutableService, Error)
    case outputStreamNoSpaceAvailable
    case unknown

    var description: String {
        switch self {
        case .noAdvertisingCharacteristic:
            return "Advertising Characteristic is nil, could not add service"

        case let .addingServiceFailed(service, error):
            return "Adding service \(service) failed with error: \(error)"

        case .outputStreamNoSpaceAvailable:
            return "OutputStream No SpaceAvailable"

        case .unknown:
            return "Unknown error"
        }
    }
}
