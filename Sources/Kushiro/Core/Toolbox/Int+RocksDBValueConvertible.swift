//
//  Int+RocksDBValueConvertible.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

// TODO: How will those keys behave if we have really a minus sign in front of the keys (negative ranges)
// Should we disable support for signed integers or do we need to encode them differently to behave
// correctly with rocksdb's dictionary order?

extension FixedWidthInteger {

    public init(data: Data) throws {
        guard let string = String(data: data, encoding: .utf8), let int = Self.init(string) else {
            throw RocksDB.Error.dataNotConvertible
        }

        self = int
    }

    public func makeData() throws -> Data {
        guard let data = String(self).data(using: .utf8) else {
            throw RocksDB.Error.dataNotConvertible
        }

        return data
    }
}

extension Int: RocksDBValueConvertible {}
extension Int8: RocksDBValueConvertible {}
extension Int16: RocksDBValueConvertible {}
extension Int32: RocksDBValueConvertible {}
extension Int64: RocksDBValueConvertible {}
