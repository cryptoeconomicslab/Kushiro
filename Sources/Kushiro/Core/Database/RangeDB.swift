//
//  RangeDB.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public struct RangeDB: RangeStore {

    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    private let kvs: KeyValueStore

    public init(keyValueStore: KeyValueStore, jsonEncoder: JSONEncoder = JSONEncoder(), jsonDecoder: JSONDecoder = JSONDecoder()) throws {
        self.kvs = keyValueStore
        self.jsonEncoder = jsonEncoder
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
        let inputRanges = try deleteBatch(valueType: Value.self, start: start, end: end)

        var outputRanges: [RangeRecord<Key, Value>] = []
        if inputRanges.count > 0 && inputRanges[0].start < start {
            outputRanges.append(RangeRecord(start: inputRanges[0].start, end: start, value: inputRanges[0].value))
        }

        if let lastRange = inputRanges.last {
            if end < lastRange.end {
                outputRanges.append(RangeRecord(start: end, end: lastRange.end, value: lastRange.value))
            }
        }

        outputRanges.append(RangeRecord(start: start, end: end, value: value))

        try putBatch(ranges: outputRanges)
    }

    public func del<Key: SignedInteger & RocksDBValueConvertible>(start: Key, end: Key) throws {
        _ = try deleteBatch(valueType: Data.self, start: start, end: end)
    }

    // MARK: - Helper functions

    private func stringFromKey<Key: RocksDBValueConvertible>(key: Key) throws -> String {
        let converted = try key.makeData()

        return converted.hexEncodedString()
    }

    private func deleteBatch<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(valueType: Value.Type? = nil, start: Key, end: Key) throws -> [RangeRecord<Key, Value>] {
        let ranges: [RangeRecord<Key, Value>] = try get(start: start, end: end)

        let operations: [RocksDBBatchOperation<Value>] = try ranges.map { range in
            return try .delete(key: stringFromKey(key: range.end))
        }

        try kvs.batch(operations: operations)

        return ranges
    }

    private func putBatch<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible>(ranges: [RangeRecord<Key, Value>]) throws {
        let operations: [RocksDBBatchOperation<Data>] = try ranges.map { range in
            return try .put(key: stringFromKey(key: range.end), value: jsonEncoder.encode(range))
        }

        try kvs.batch(operations: operations)
    }
}
