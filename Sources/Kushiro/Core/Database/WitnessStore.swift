//
//  WitnessStore.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public protocol WitnessStore {

    func storeWitness<Value: RocksDBValueConvertible>(key: String, witness: Value) throws

    func getWitness<Value: RocksDBValueConvertible>(key: String) throws -> Value
}

public struct KVSWitnessStore: WitnessStore {

    private let kvs: KeyValueStore

    public init(keyValueStore: KeyValueStore) {
        self.kvs = keyValueStore
    }

    public func storeWitness<Value: RocksDBValueConvertible>(key: String, witness: Value) throws {
        try kvs.put(key: key, value: witness)
    }

    public func getWitness<Value: RocksDBValueConvertible>(key: String) throws -> Value {
        return try kvs.get(key: key)
    }
}

public protocol RangeWitnessStore {

    func storeWitness<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key, witness: Value) throws

    func getWitness<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key) throws -> [RangeRecord<Key, Value>]
}

public struct KVSRangeWitnessStore: RangeWitnessStore {

    private let rangeStore: RangeStore

    public init(rangeStore: RangeStore) {
        self.rangeStore = rangeStore
    }

    public func storeWitness<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key, witness: Value) throws {
        try rangeStore.put(start: start, end: end, value: witness)
    }

    public func getWitness<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key) throws -> [RangeRecord<Key, Value>] {
        return try rangeStore.get(start: start, end: end)
    }
}
