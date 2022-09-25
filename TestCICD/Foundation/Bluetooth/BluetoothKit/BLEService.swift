//
//  Service.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

struct BLEService: PeripheralAttribute {
    let value: CBService
    private let peripheral: Peripheral

    init(value: CBService, peripheral: Peripheral) {
        self.value = value
        self.peripheral = peripheral
    }

    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?) -> AnyPublisher<BLECharacteristic, Never> {
        peripheral.discoverCharacteristics(characteristicUUIDs: characteristicUUIDs, for: value)
    }
}
