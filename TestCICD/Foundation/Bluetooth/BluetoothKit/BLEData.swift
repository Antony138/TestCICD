//
//  BLEData.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

struct BLEData: PeripheralAttribute {
    let value: Data
    let peripheral: Peripheral

    init(value: Data, peripheral: Peripheral) {
        self.value = value
        self.peripheral = peripheral
    }
}
