//
//  InMemoryKeyValueStore.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public struct InMemoryKeyValueStore: KeyValueStore {

    public typealias Key = String
    public typealias Value = Data

    private let rocksDB: RocksDB

    public init(prefix: String? = nil, ramfsDirectory: URL) throws {
        let dbPath = ramfsDirectory.appendingPathComponent(UUID().uuidString)
        self.rocksDB = try RocksDB(path: dbPath, prefix: prefix)
    }

    public func get<Value: RocksDBValueConvertible>(valueType: Value.Type, key: String) throws -> Value {
        return try rocksDB.get(type: Value.self, key: key)
    }

    public func put<Value: RocksDBValueConvertible>(key: String, value: Value) throws {
        try rocksDB.put(key: key, value: value)
    }

    public func del(key: String) throws {
        try rocksDB.delete(key: key)
    }

    public func sequence<Value: RocksDBValueConvertible>(valueType: Value.Type, gte: String) throws -> RocksDBSequence<String, Value> {
        return rocksDB.sequence(gte: gte)
    }

    public func sequence<Value: RocksDBValueConvertible>(valueType: Value.Type, lte: String) throws -> RocksDBSequence<String, Value> {
        return rocksDB.sequence(lte: lte)
    }

    public func batch<Value: RocksDBValueConvertible>(valueType: Value.Type, operations: [RocksDBBatchOperation<Value>]) throws {
        return try rocksDB.batch(operations: operations)
    }
}
