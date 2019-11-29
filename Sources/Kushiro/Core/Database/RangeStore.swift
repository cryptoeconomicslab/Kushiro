//
//  RangeStore.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public protocol RangeStore {

    func get<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key) throws -> [RangeRecord<Key, Value>]

    func put<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key, value: Value) throws

    func del<Key: SignedInteger & RocksDBValueConvertible>(start: Key, end: Key) throws
}
