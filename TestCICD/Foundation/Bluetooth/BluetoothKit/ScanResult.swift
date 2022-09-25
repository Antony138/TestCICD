//
//  ScanResult.swift
//  EVP4
//
//  Created by Antony Wong on 2022/07/29.
//

import Foundation
import CoreBluetooth

class ScanResult {
    let centralManager: CentralManager
    let peripheral: CBPeripheral
    let advertisementData: [String: Any]
    let rssi: NSNumber

    init(centralManager: CentralManager, peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}
