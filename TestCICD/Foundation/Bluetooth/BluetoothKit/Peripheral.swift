//
//  Peripheral.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/01.
//

import Foundation
import CoreBluetooth
import Combine

class Peripheral: NSObject, PeripheralType {
    private var cbPeripheral: CBPeripheral

    private let didDiscoverServices = PassthroughSubject<CBPeripheral, Never>()
    private let didDiscoverCharacteristics = PassthroughSubject<(peripheral: CBPeripheral, service: CBService), Never>()
    private let didUpdateValue = PassthroughSubject<Data, Never>()
    private let didOpenL2CAPChannel = PassthroughSubject<(peripheral: CBPeripheral, channel: CBL2CAPChannel), Never>()

    private var cancellableSet: Set<AnyCancellable> = []

    static func configureWith(_ cbPeripheral: CBPeripheral) -> Peripheral {
        let peripheral = Peripheral(cbPeripheral: cbPeripheral)
        peripheral.setupDelegate()
        return peripheral
    }

    init(cbPeripheral: CBPeripheral) {
        self.cbPeripheral = cbPeripheral
    }

    // MARK: - Interface

    func discoverServices(serviceUUIDs: [CBUUID]?) -> AnyPublisher<BLEService, Never> {
        let subject = PassthroughSubject<BLEService, Never>()

        cbPeripheral.discoverServices(serviceUUIDs)

        didDiscoverServices.compactMap { $0.services }
            .sink { [weak self] services in
                guard let self = self else {
                    print("@@@ BluetoothKit: deallocated")
                    return
                }
                services.forEach {
                    subject.send(BLEService(value: $0, peripheral: self))
                }
                subject.send(completion: .finished)
            }
            .store(in: &cancellableSet)

        return subject.eraseToAnyPublisher()
    }

    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, for service: CBService) -> AnyPublisher<BLECharacteristic, Never> {
        let subject = PassthroughSubject<BLECharacteristic, Never>()

        cbPeripheral.discoverCharacteristics(characteristicUUIDs, for: service)

        didDiscoverCharacteristics.compactMap { $0.service.characteristics }
            .sink { [weak self] characteristics in
                guard let self = self else {
                    print("@@@ BluetoothKit: deallocated")
                    return
                }
                characteristics.forEach {
                    subject.send(BLECharacteristic(value: $0, peripheral: self))
                }
                subject.send(completion: .finished)
            }
            .store(in: &cancellableSet)

        return subject.eraseToAnyPublisher()
    }

    func observeValue(for characteristic: CBCharacteristic) -> AnyPublisher<BLEData, Never> {
        cbPeripheral.readValue(for: characteristic)

        return didUpdateValue.map { BLEData(value: $0, peripheral: self) }.eraseToAnyPublisher()
    }

    func openL2CAPChannel(_ PSM: CBL2CAPPSM) -> AnyPublisher<L2CAPChannel, Never> {
        cbPeripheral.openL2CAPChannel(PSM)

        return didOpenL2CAPChannel.map { L2CAPChannel(cbChannel: $0.channel) }.eraseToAnyPublisher()
    }

    // MARK: - private

    private func setupDelegate() {
        cbPeripheral.delegate = self
    }
}

// MARK: - CBPeripheralDelegate

extension Peripheral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("@@@ BluetoothKit: didDiscoverServices: \(String(describing: peripheral.services))")
        didDiscoverServices.send(peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("@@@ BluetoothKit: didDiscoverCharacteristicsFor: \(String(describing: service.characteristics))")
        didDiscoverCharacteristics.send((peripheral, service))
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("@@@ BluetoothKit: didUpdateValue(received data): \(String(describing: characteristic.value))")
        guard let data = characteristic.value else {
            print("@@@ BluetoothKit: characteristic.value is nil")
            return
        }
        didUpdateValue.send(data)
    }

    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("@@@ BluetoothKit: didOpen L2CAP Channel: \(String(describing: channel?.psm))")
        guard let channel = channel else {
            print("@@@ BluetoothKit: L2CAP channel is nil")
            return
        }
        didOpenL2CAPChannel.send((peripheral, channel))
    }
}
