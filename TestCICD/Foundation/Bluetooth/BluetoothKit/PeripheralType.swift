//
//  PeripheralType.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

protocol PeripheralType {
    /// Discovers the specified services of the peripheral.
    /// - Parameter serviceUUIDs: An array of CBUUID objects that you are interested in. Each CBUUID object represents a UUID that identifies the type of service you want to discover.
    /// - Returns: Customized `BLEService` object: `CBService`, `Peripheral`, Interface method `discoverCharacteristics()`
    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, Never>

    /// Discovers the specified characteristics of a service.
    /// - Parameters:
    ///   - characteristicUUIDs: An array of CBUUID objects that you are interested in. Each CBUUID object represents a UUID that identifies the type of a characteristic you want to discover.
    ///   - service: The service whose characteristics you want to discover.
    /// - Returns: Customized `BLECharacteristic` object: `CBCharacteristic`, `Peripheral`, Interface method `observeValue()`
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, Never>

    /// Retrieves the value of a specified characteristic.
    /// - Parameter characteristic: The characteristic whose value you want to read.
    /// - Returns: Customized `BLEData` object: `Data`, `Peripheral`(Use to call `openL2CAPChannel()`)
    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, Never>

    /// Attempt to open an L2CAP channel to the peripheral using the supplied PSM.  
    /// - Parameter PSM: The PSM of the channel to open
    /// - Returns: Customized `L2CAPChannel` object: use to setup Stream and receive data
    func openL2CAPChannel(_ PSM: CBL2CAPPSM) -> AnyPublisher<L2CAPChannel, Never>
}
