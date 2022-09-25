//
//  PeripheralManagerType.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/02.
//
// ***
// NOTE: Peripheral Manager just uses to simulate Meter's broadcast when we do not have the real Meter. Not for iOS App
// ***
//

import Foundation
import CoreBluetooth
import Combine

typealias AddServiceResult = (peripheralManager: PeripheralManager, service: CBService)

protocol PeripheralManagerType {
    /// Publishes a service and any of its associated characteristics and characteristic descriptors to the local GATT database.
    /// - Parameters:
    ///   - service: The service you want to publish.
    ///   - characteristic: The characteristic you want to publish.
    /// - Returns: Tuple `AddServiceResult`: `PeripheralManager`, `CBService`
    func add(service: CBMutableService, characteristic: CBMutableCharacteristic) -> AnyPublisher<AddServiceResult, BluetoothError>

    /// Advertises peripheral manager data; Creates a listener for incoming L2CAP channel connections (publishL2CAPChannel).
    /// - Parameter advertisementData: An optional dictionary containing the data you want to advertise. The peripheral manager only supports two keys: CBAdvertisementDataLocalNameKey and CBAdvertisementDataServiceUUIDsKey.
    /// - Returns: Customized `L2CAPChannel` object: use to setup Stream and receive data
    func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<L2CAPChannel, Never>
}
