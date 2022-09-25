//
//  CentralManager.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

class CentralManager: NSObject, CentralManagerType {
    private var cbCentralManager: CBCentralManager

    private let didDiscoverPeripheral = PassthroughSubject<ScanResult, Never>()
    private let didConnectPeripheral = PassthroughSubject<ConnectResult, Never>()

    private var discoveredPeripherals = Set<CBPeripheral>()

    private var connectedPeripherals = [UUID: Peripheral]()

    private var isStopScanAfterConected = false

    static func configureWith(_ cbCentralManager: CBCentralManager) -> CentralManager {
        let centralManager = CentralManager(cbCentralManager: cbCentralManager)
        centralManager.setupDelegate()
        return centralManager
    }

    init(cbCentralManager: CBCentralManager) {
        self.cbCentralManager = cbCentralManager
    }

    // MARK: - Interface

    func scanPeripherals(withServices services: [CBUUID]?, options: [String: Any]?) -> AnyPublisher<ScanResult, Never> {
        cbCentralManager.scanForPeripherals(withServices: services, options: options)

        return didDiscoverPeripheral.handleEvents(receiveOutput: { [weak self] in
            guard let self = self else {
                print("@@@ BluetoothKit: deallocated")
                return
            }

            guard self.discoveredPeripherals.contains($0.peripheral) == false else {
                print("@@@ BluetoothKit: didDiscover: \($0.peripheral), but already in discoveredPeripherals ignore")
                return
            }

            self.discoveredPeripherals.insert($0.peripheral)
        })
        .eraseToAnyPublisher()
    }

    func connect(peripheral: CBPeripheral, options: [String: Any]?, isStopScanAfterConected: Bool) -> AnyPublisher<ConnectResult, Never> {
        cbCentralManager.connect(peripheral)

        return didConnectPeripheral.eraseToAnyPublisher()
    }

    // MARK: - private

    private func setupDelegate() {
        cbCentralManager.delegate = self
    }

    private func stopScanPeripherals() {
        cbCentralManager.stopScan()
        discoveredPeripherals.removeAll()
    }
}

// MARK: - CBCentralManagerDelegate

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("@@@ BluetoothKit: centralManagerDidUpdateState: \(central.state)")
        // TODO: handle the state
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("@@@ BluetoothKit: didDiscover: \(peripheral)")
        let scanResult = ScanResult(centralManager: self, peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        didDiscoverPeripheral.send(scanResult)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("@@@ BluetoothKit: didConnect: \(peripheral)")
        let connectedPeripheral = Peripheral.configureWith(peripheral)
        let connectResult = ConnectResult(central: central, connectedPeripheral:connectedPeripheral)
        connectedPeripherals[peripheral.identifier] = connectedPeripheral
        didConnectPeripheral.send(connectResult)

        if isStopScanAfterConected {
            stopScanPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("@@@ BluetoothKit: didDisconnectPeripheral: \(peripheral)")
        connectedPeripherals[peripheral.identifier] = nil
    }
}
