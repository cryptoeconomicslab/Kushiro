//
//  RangeDB.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public struct RangeDB: RangeStore {

    private let jsonDecoder: JSONDecoder

    private let kvs: KeyValueStore

    public init(keyValueStore: KeyValueStore, jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        self.kvs = keyValueStore
        self.jsonDecoder = jsonDecoder
    }

    public func get<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key) throws -> [RangeRecord<Key, Value>] {
        let startStr = try stringFromKey(key: start)
        let iterator = try kvs.sequence(valueType: Data.self, gte: startStr).makeIterator()

        guard let first = iterator.next() else {
            return []
        }

        var rangeRecords: [RangeRecord<Key, Value>] = []
        var range = try jsonDecoder.decode(RangeRecord<Key, Value>.self, from: first.value)
        while range.intersects(start: start, end: end) {
            rangeRecords.append(range)

            guard let next = iterator.next() else {
                break
            }

            range = try jsonDecoder.decode(RangeRecord<Key, Value>.self, from: next.value)
        }

        return rangeRecords
    }

    public func put<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(start: Key, end: Key, value: Value) throws {

    }

    public func del<Key>(start: Key, end: Key) throws where Key : RocksDBValueInitializable, Key : RocksDBValueRepresentable, Key : SignedInteger {

    }

    // MARK: - Helper functions

    private func stringFromKey<Key: RocksDBValueConvertible>(key: Key) throws -> String {
        let converted = try key.makeData()

        return converted.hexEncodedString()
    }
}
