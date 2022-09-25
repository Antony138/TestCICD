//
//  BluetoothKit.swift
//  EVP4
//
//  Created by Antony Wong on 2022/07/29.
//

import Foundation
import CoreBluetooth

struct BluetoothKit {
    let centralManager: CentralManagerType
    let peripheralManager: PeripheralManagerType

    init() {
        centralManager = CentralManager.configureWith(CBCentralManager())
        peripheralManager = PeripheralManager.configureWith(CBPeripheralManager())
    }
}
