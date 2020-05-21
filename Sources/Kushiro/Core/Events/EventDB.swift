//
//  EventDB.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation

public struct EventDB {

    public let kvs: KeyValueStore

    public init(kvs: KeyValueStore) {
        // TODO: Bucket this as in wakkanay
        self.kvs = kvs
    }

    public func getLastLoggedBlock(topic: Data) throws -> Int {
        let result: String = try kvs.get(key: topic.hexEncodedString())

        return result == "" ? 0 : Int(result, radix: 10) ?? 0
    }

    public func setLastLoggedBlock(topic: Data, loaded: Int) throws {
        try kvs.put(key: topic.hexEncodedString(), value: String(loaded, radix: 10))
    }

    public func addSeen(event: Data) throws {
        try kvs.put(key: event.hexEncodedString(), value: "true")
    }

    public func getSeen(event: Data) throws -> Bool {
        let result: String = try kvs.get(key: event.hexEncodedString())

        return result != ""
    }
}
