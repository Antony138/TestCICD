//
//  L2CAPChannel.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/02.
//

import Foundation
import CoreBluetooth
import Combine

class L2CAPChannel: NSObject, L2CAPChannelType {
    var cbChannel: CBL2CAPChannel

    private let didUpdateStreamForL2CAPChannel = PassthroughSubject<(aStream: Stream, eventCode: Stream.Event), Never>()

    init(cbChannel: CBL2CAPChannel) {
        self.cbChannel = cbChannel
    }

    // MARK: - Interface

    func setupL2CAPChannel(_ channel: CBL2CAPChannel) -> AnyPublisher<L2CAPChannelResult, Never> {
        setupAndOpenStream(channel)

        return didUpdateStreamForL2CAPChannel.map { L2CAPChannelResult(self, $0.aStream, $0.eventCode) }.eraseToAnyPublisher()
    }

    func send(data: Data) -> SendResult {
        guard cbChannel.outputStream.hasSpaceAvailable else {
            print("@@@ BluetoothKit: outputStream is not Available")
            return SendResult(nil, BluetoothError.outputStreamNoSpaceAvailable)
        }

        let bytesWritten = cbChannel.outputStream.write(data)
        print("@@@ BluetoothKit: send data: \(bytesWritten) bytes")
        return SendResult(bytesWritten, nil)
    }

    // MARK: - private

    private func setupAndOpenStream(_ channel: CBL2CAPChannel) {
        channel.inputStream.delegate = self
        channel.outputStream.delegate = self
        channel.inputStream.schedule(in: RunLoop.main, forMode: .default)
        channel.outputStream.schedule(in: RunLoop.main, forMode: .default)
        channel.inputStream.open()
        channel.outputStream.open()
        print("@@@ BluetoothKit: Setup inputStream, outputStream")
    }
}

// MARK: - StreamDelegate

extension L2CAPChannel: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        didUpdateStreamForL2CAPChannel.send((aStream, eventCode))
        switch eventCode {
        case Stream.Event.openCompleted:
            print("@@@ BluetoothKit: L2CAP Stream is Open. \(aStream)")

        case Stream.Event.endEncountered:
            print("@@@ BluetoothKit: L2CAP Stream is End Encountered. \(aStream)")

        case Stream.Event.hasBytesAvailable:
            print("@@@ BluetoothKit: L2CAP Stream hasBytesAvailable. \(aStream)")

        case Stream.Event.hasSpaceAvailable:
            print("@@@ BluetoothKit: L2CAP Stream hasSpaceAvailable. \(aStream)")

        case Stream.Event.errorOccurred:
            print("@@@ BluetoothKit: L2CAP Stream Error Occurred. \(aStream)")

        default:
            print("@@@ BluetoothKit: L2CAP Stream Unknown Stream Event. \(aStream)")
        }
    }
}
