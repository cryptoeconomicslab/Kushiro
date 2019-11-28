//
//  KeyValueStore.swift
//  Kushiro
//
//  Created by Koray Koska on 28.11.19.
//

import Foundation
import RocksDB

public protocol KeyValueStore {

    associatedtype Key: RocksDBValueConvertible
    associatedtype Value: RocksDBValueConvertible

    func get(key: Key) throws -> Value

    func put(key: Key, value: Value) throws

    func del(key: Key) throws

    func sequence(gte: Key) throws -> RocksDBSequence<Key, Value>

    func sequence(lte: Key) throws -> RocksDBSequence<Key, Value>
}
