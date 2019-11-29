//
//  Int+RocksDBValueConvertible.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

extension Int64: RocksDBValueConvertible {

    public init(data: Data) throws {
        self = data.withUnsafeBytes {
            $0.bindMemory(to: Int64.self)[0].littleEndian
        }
    }

    public func makeData() throws -> Data {
        return withUnsafeBytes(of: self.littleEndian) { Data($0) }
    }
}
