# BluetoothKit

Bridges Apple's `CoreBluetooth` framework and Apple's `Combine` framework

[BluetoothKit Code Structure](https://miro.com/app/board/uXjVOigMi_s=/?moveToWidget=3458764530482703572&cot=14)

## Usage

- **Open the L2CAP channel in central side**
```
BluetoothKit.shared.centralManager
    .scanPeripherals(withServices: [L2CAP.serviceUUID], options: nil)
    .flatMap { $0.centralManager.connect(peripheral: $0.peripheral, options: nil, isStopScanAfterConected: true) }
    .flatMap { $0.connectedPeripheral.discoverServices(serviceUUIDs: [L2CAP.serviceUUID]) }
    .flatMap { $0.discoverCharacteristics(characteristicUUIDs: [L2CAP.PSMUUID]) }
    .flatMap { $0.observeValue() }
    .flatMap { $0.peripheral.openL2CAPChannel($0.value.uint16) }
    .flatMap { $0.setupL2CAPChannel($0.cbChannel) }
    .sink { [weak self] result in
        switch result.eventCode {
        case Stream.Event.openCompleted:
            print("@ Demo: L2CAP Stream is open")
            self?.centralL2CAPChannel = result.channel

        case Stream.Event.endEncountered:
            print("@ Demo: L2CAP End Encountered")

        case Stream.Event.hasBytesAvailable:
            print("@ Demo: L2CAP Has Bytes Available: \(result.aStream)")
            // Read data in here

        case Stream.Event.hasSpaceAvailable:
            print("@ Demo: L2CAP Has Space Available")
            // You can send data if `hasSpaceAvailable`

        case Stream.Event.errorOccurred:
            print("@ Demo: L2CA Stream error")

        default:
            print("@ Demo: L2CA Unknown stream event")
        }
    }
    .store(in: &cancellableSet)
```

- **Publish a L2CAP Channel in peripheral side**
```
let service = CBMutableService(type: L2CAP.serviceUUID, primary: true)
let characteristic = CBMutableCharacteristic(type: L2CAP.PSMUUID, properties: [.read, .indicate], value: nil, permissions: [.readable])
BluetoothKit.shared.peripheralManager.add(service: service, characteristic: characteristic)
    .flatMap { $0.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [L2CAP.serviceUUID]]) }
    .flatMap { $0.setupL2CAPChannel($0.cbChannel) }
    .sink { [weak self] result in
        switch result.eventCode {
        case Stream.Event.openCompleted:
            print("@ Demo: L2CAP Stream is open")
            self?.peripheralL2CAPChannel = result.channel

        case Stream.Event.endEncountered:
            print("@ Demo: L2CAP End Encountered")

        case Stream.Event.hasBytesAvailable:
            print("@ Demo: L2CAP Has Bytes Available: \(result.aStream)")

        case Stream.Event.hasSpaceAvailable:
            print("@ Demo: L2CAP Has Space Available")

        case Stream.Event.errorOccurred:
            print("@ Demo: L2CA Stream error")

        default:
            print("@ Demo: L2CA Unknown stream event")
        }
    }
    .store(in: &cancellableSet)
```
