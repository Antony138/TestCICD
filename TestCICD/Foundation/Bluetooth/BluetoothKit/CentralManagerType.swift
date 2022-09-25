//
//  CentralManagerType.swift
//  EVP4
//
//  Created by Antony Wong on 2022/07/29.
//

import Foundation
import CoreBluetooth
import Combine

protocol CentralManagerType {
    /// Scans for peripherals that are advertising services.
    /// - Parameters:
    ///   - services: An array of CBUUID objects that the app is interested in. Each CBUUID object represents the UUID of a service that a peripheral advertises.
    ///   - options: A dictionary of options for customizing the scan. For available options, see Peripheral Scanning Options.
    /// - Returns: ScanResult: `CentralManager`, `CBPeripheral`, `advertisementData`, `rssi`
    func scanPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<ScanResult, Never>

    /// Establishes a local connection to a peripheral.
    /// - Parameters:
    ///   - peripheral: The peripheral to which the central is attempting to connect.
    ///   - options: A dictionary to customize the behavior of the connection. For available options, see Peripheral Connection Options.
    ///   - isStopScanAfterConected: Whether to stop scanning after successful connection
    /// - Returns: ConnectResult: `CBCentralManager`, `Peripheral`
    func connect(peripheral: CBPeripheral, options: [String: Any]?, isStopScanAfterConected: Bool) -> AnyPublisher<ConnectResult, Never>
}
