//
//  KeyValueStore.swift
//  Kushiro
//
//  Created by Koray Koska on 28.11.19.
//

import Foundation
import RocksDB

public protocol KeyValueStore {

    func get<Value: RocksDBValueConvertible>(valueType: Value.Type, key: String) throws -> Value

    func put<Value: RocksDBValueConvertible>(key: String, value: Value) throws

    func del(key: String) throws

    func sequence<Value: RocksDBValueConvertible>(valueType: Value.Type, gte: String) throws -> RocksDBSequence<String, Value>

    func sequence<Value: RocksDBValueConvertible>(valueType: Value.Type, lte: String) throws -> RocksDBSequence<String, Value>
}

public extension KeyValueStore {

    func get<Value: RocksDBValueConvertible>(key: String) throws -> Value {
        return try get(valueType: Value.self, key: key)
    }

    func sequence<Value: RocksDBValueConvertible>(gte: String) throws -> RocksDBSequence<String, Value> {
        return try sequence(valueType: Value.self, gte: gte)
    }

    func sequence<Value: RocksDBValueConvertible>(lte: String) throws -> RocksDBSequence<String, Value> {
        return try sequence(valueType: Value.self, lte: lte)
    }
}
