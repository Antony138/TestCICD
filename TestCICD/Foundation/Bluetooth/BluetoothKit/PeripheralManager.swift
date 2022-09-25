//
//  PeripheralManager.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/02.
//

import Foundation
import CoreBluetooth
import Combine

class PeripheralManager: NSObject, PeripheralManagerType {
    private var cbPeripheralManager: CBPeripheralManager

    private let didAddService = PassthroughSubject<(peripheral: CBPeripheralManager, service: CBService, error: Error?), Never>()
    private let didOpenL2CAPChannel = PassthroughSubject<(peripheralManager: CBPeripheralManager, channel: CBL2CAPChannel), Never>()

    private var advertisingCharacteristic: CBMutableCharacteristic?
    private var channelPSM: CBL2CAPPSM?

    private var subscribedCentrals = [CBCharacteristic: [CBCentral]]()

    static func configureWith(_ cbPeripheralManager: CBPeripheralManager) -> PeripheralManager {
        let peripheralManager = PeripheralManager(cbPeripheralManager: cbPeripheralManager)
        peripheralManager.setupDelegate()
        return peripheralManager
    }

    init(cbPeripheralManager: CBPeripheralManager) {
        self.cbPeripheralManager = cbPeripheralManager
    }

    // MARK: - Interface

    func add(service: CBMutableService, characteristic: CBMutableCharacteristic) -> AnyPublisher<AddServiceResult, BluetoothError> {
        advertisingCharacteristic = characteristic

        guard let advertisingCharacteristic = advertisingCharacteristic else {
            print("@@@ BluetoothKit: advertisingService or advertisingCharacteristic is nil")
            return Fail<AddServiceResult, BluetoothError>(error: BluetoothError.noAdvertisingCharacteristic).eraseToAnyPublisher()
        }

        service.characteristics = [advertisingCharacteristic]

        cbPeripheralManager.add(service)

        return didAddService
            .tryMap { _, cbService, error throws -> AddServiceResult in
                if let error = error {
                    throw error
                }
                return AddServiceResult(self, cbService)
            }
            .mapError { BluetoothError.addingServiceFailed(service, $0) }
            .eraseToAnyPublisher()
    }

    func startAdvertising(_ advertisementData: [String: Any]?) -> AnyPublisher<L2CAPChannel, Never> {
        cbPeripheralManager.startAdvertising(advertisementData)
        cbPeripheralManager.publishL2CAPChannel(withEncryption: false)

        return didOpenL2CAPChannel.map { L2CAPChannel(cbChannel: $0.channel) }.eraseToAnyPublisher()
    }

    // MARK: - private

    private func setupDelegate() {
        cbPeripheralManager.delegate = self
    }

    private func sendPSMToCentral() {
        guard let advertisingCharacteristic = advertisingCharacteristic else {
            print("@@@ BluetoothKit: advertisingCharacteristic is nil, return")
            return
        }

        advertisingCharacteristic.value = channelPSM?.data

        guard let value = self.channelPSM?.data else {
            print("@@@ BluetoothKit: channel PSM is nil")
            return
        }

        cbPeripheralManager.updateValue(value, for: advertisingCharacteristic, onSubscribedCentrals: subscribedCentrals[advertisingCharacteristic])
    }
}

// MARK: - CBPeripheralManagerDelegate

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // TODO: unitize log
        print("@@@ BluetoothKit: peripheralManagerDidUpdateState: \(peripheral.state)")
        // TODO: handle the state
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("@@@ BluetoothKit: didAdd service: \(String(describing: service))")
        didAddService.send((peripheral, service, error))
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("@@@ BluetoothKit: didStartAdvertising: \(String(describing: peripheral))")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("@@@ BluetoothKit: didSubscribeTo: \(String(describing: characteristic))")
        var centrals = subscribedCentrals[characteristic, default: [CBCentral]()]
        centrals.append(central)
        subscribedCentrals[characteristic]  = centrals
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("@@@ BluetoothKit: didPublishL2CAPChannel: \(PSM)")
        channelPSM = PSM
        sendPSMToCentral()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("@@@ BluetoothKit: didReceiveRead: \(request)")
        if let characteristic = advertisingCharacteristic {
            request.value = characteristic.value
            cbPeripheralManager.respond(to: request, withResult: .success)
        } else {
            cbPeripheralManager.respond(to: request, withResult: .unlikelyError)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("@@@ BluetoothKit: didOpen L2CAP Channel: \(String(describing: channel?.psm))")
        guard let channel = channel else {
            print("@@@ BluetoothKit: L2CAP channel is nil")
            return
        }
        didOpenL2CAPChannel.send((peripheral, channel))
    }
}
