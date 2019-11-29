//
//  RangeRecord.swift
//  Kushiro
//
//  Created by Koray Koska on 29.11.19.
//

import Foundation
import RocksDB

public struct RangeRecord<Key: SignedInteger & RocksDBValueConvertible, Value: RocksDBValueConvertible> {

    public let start: Key

    public let end: Key

    public let value: Value

    public init(start: Key, end: Key, value: Value) {
        self.start = start
        self.end = end
        self.value = value
    }

    public func intersects(start: Key, end: Key) -> Bool {
        // TODO: Should we throw here instead of returning false or do we need a `Range` struct?
        if end <= start {
            return false
        }
        if start < 0 {
            return false
        }

        return max(self.start, start) < min(self.end, end)
    }
}

extension RangeRecord: Codable {

    enum CodingKeys: String, CodingKey {

        case start
        case end
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.start = try keyFromString(string: container.decode(String.self, forKey: .start))
        self.end = try keyFromString(string: container.decode(String.self, forKey: .end))
        self.value = try keyFromString(string: container.decode(String.self, forKey: .end))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(stringFromKey(key: start), forKey: .start)
        try container.encode(stringFromKey(key: end), forKey: .end)
        try container.encode(stringFromKey(key: value), forKey: .value)
    }

    // MARK: - Helper functions

    private func stringFromKey<Key: RocksDBValueConvertible>(key: Key) throws -> String {
        let converted = try key.makeData()

        return converted.hexEncodedString()
    }

    private func keyFromString<Key: RocksDBValueConvertible>(string: String) throws -> Key {
        let converted = string.hexDecodedData()

        return try Key.init(data: converted)
    }
}
