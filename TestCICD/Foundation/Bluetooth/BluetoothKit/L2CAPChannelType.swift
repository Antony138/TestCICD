//
//  L2CAPChannelType.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/02.
//

import Foundation
import CoreBluetooth
import Combine

typealias L2CAPChannelResult = (channel: L2CAPChannel, aStream: Stream, eventCode: Stream.Event)
typealias SendResult = (bytesWritten: Int?, error: BluetoothError?)

protocol L2CAPChannelType {
    /// Setup inputStream, outputStream's delegate, schedule and open them
    /// - Parameter channel: The `CBL2CAPChannel`object return in `didOpen` callback method
    /// - Returns: Tuple L2CAPChannelResult: `CBL2CAPChannel`, `Stream`(will get Data from here), `Stream.Event`
    func setupL2CAPChannel(_ channel: CBL2CAPChannel) -> AnyPublisher<L2CAPChannelResult, Never>

    /// Send data over L2CAP channel
    /// - Parameter data: The data what you want to send.
    /// - Returns: Tuple SendResult: bytesWritten, how many bytes were sent; `BluetoothError`
    func send(data: Data) -> SendResult
}
