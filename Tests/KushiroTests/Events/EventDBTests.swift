//
//  EventDBTests.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import XCTest
import Quick
import Nimble
@testable import Kushiro

final class EventDBTests: QuickSpec {

    override func spec() {
        describe("event db tests") {

            let dbName = "root"
            let topic = "topic".data(using: .utf8)!

            context("general tests") {
                it("should per default return 0 for last logged block") {
                    let kvs = try! InMemoryKeyValueStore(prefix: dbName, ramfsDirectory: URL(fileURLWithPath: "/tmp", isDirectory: true))
                    let eventDB = EventDB(kvs: kvs)
                    let block = try! eventDB.getLastLoggedBlock(topic: topic)

                    expect(block).to(equal(0))
                }

                it("should succeed to setLastLoggedBlock") {
                    let kvs = try! InMemoryKeyValueStore(prefix: dbName, ramfsDirectory: URL(fileURLWithPath: "/tmp", isDirectory: true))
                    let eventDB = EventDB(kvs: kvs)
                    try! eventDB.setLastLoggedBlock(topic: topic, loaded: 100)
                    let block = try! eventDB.getLastLoggedBlock(topic: topic)

                    expect(block).to(equal(100))
                }
            }
        }
    }
}
