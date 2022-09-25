//
//  BluetoothKitExtension.swift
//  EVP4
//
//  Created by Antony Wong on 2022/08/02.
//

import Foundation

// MARK: - Data

extension Data {
    /// Use to read binary data from L2CAP channel
    /// - Parameter input: `InputStream` from `StreamDelegate`
    init(reading input: InputStream) throws {
        self.init()

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Stream error occured
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            append(buffer, count: read)
        }
    }

    init?(hex: String) {
        guard !hex.isEmpty,
              hex.isHex,
              let data = hex.data(using: .utf8) else {
            return nil
        }

        self = data
    }

    var uint16: UInt16 {
        withUnsafeBytes { $0.load(as: UInt16.self) }
    }
}

// MARK: - Number

extension UInt16 {
    /// LittleEndian. Example:  192 will return 0xC000
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

// MARK: - String

extension String {
    var isHex: Bool {
        filter(\.isHexDigit).count == count
    }
}

// MARK: - OutputStream

extension OutputStream {
    func write(_ data: Data) -> Int {
        data.withUnsafeBytes { rawBufferPointer -> Int in
            let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
            return self.write(bufferPointer.baseAddress!, maxLength: data.count)
        }
    }
}
