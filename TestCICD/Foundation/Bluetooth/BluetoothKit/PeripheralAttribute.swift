//
//  PeripheralAttribute.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth

/// Represents properties on the Peripheral side
/// E.g.: BLEService, BLECharacteristic, BLEData
protocol PeripheralAttribute {
    associatedtype AttributeType

    var value: AttributeType { get }

    init(value: AttributeType, peripheral: Peripheral)
}
