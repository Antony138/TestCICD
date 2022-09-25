//
//  BLECharacteristic.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

struct BLECharacteristic: PeripheralAttribute {
    let value: CBCharacteristic
    private let peripheral: Peripheral

    init(value: CBCharacteristic, peripheral: Peripheral) {
        self.value = value
        self.peripheral = peripheral
    }

    func observeValue() -> AnyPublisher<BLEData, Never> {
        peripheral.observeValue(for: value)
    }
}
