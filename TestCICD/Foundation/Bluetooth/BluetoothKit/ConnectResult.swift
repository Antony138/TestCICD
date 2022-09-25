//
//  ConnectResult.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth

class ConnectResult {
    let central: CBCentralManager
    let connectedPeripheral: Peripheral

    init(central: CBCentralManager, connectedPeripheral: Peripheral) {
        self.central = central
        self.connectedPeripheral = connectedPeripheral
    }
}
