//
//  RangeDBTests.swift
//  KushiroTests
//
//  Created by Koray Koska on 01.12.19.
//

import XCTest
import Quick
import Nimble
@testable import Kushiro

final class RangeDBTests: QuickSpec {

    override func spec() {
        describe("range db tests") {

            var kvs: InMemoryKeyValueStore! = nil
            var rangeDB: RangeDB! = nil
            let alice = "alice"
            let bob = "bob"
            let carol = "carol"

            beforeEach {
                kvs = try! InMemoryKeyValueStore(ramfsDirectory: URL(fileURLWithPath: "/tmp", isDirectory: true))
                rangeDB = try! RangeDB(keyValueStore: kvs)
            }

            context("get ranges") {
                it("should have 3 elements") {
                    try! rangeDB.put(start: 0, end: 100, value: alice)
                    try! rangeDB.put(start: 100, end: 200, value: bob)
                    try! rangeDB.put(start: 200, end: 300, value: carol)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 0, end: 300)

                    expect(ranges.count).to(equal(3))
                }
            }

            context("get small range") {
                it("should have 1 element") {
                    try! rangeDB.put(start: 120, end: 150, value: alice)
                    try! rangeDB.put(start: 0, end: 20, value: bob)
                    try! rangeDB.put(start: 500, end: 600, value: carol)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 100, end: 200)

                    expect(ranges.count).to(equal(1))
                }
            }

            context("get large range") {
                it("should have 1 element") {
                    try! rangeDB.put(start: 0, end: 500, value: alice)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 100, end: 200)

                    expect(ranges.count).to(equal(1))
                }
            }

            context("edges") {
                it("should not include the edge") {
                    try! rangeDB.put(start: 80, end: 100, value: alice)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 100, end: 200)

                    expect(ranges.count).to(equal(0))
                }
            }

            context("delete ranges") {
                it("should not include deleted ranges") {
                    try! rangeDB.put(start: 0, end: 100, value: alice)
                    try! rangeDB.put(start: 100, end: 200, value: bob)
                    try! rangeDB.put(start: 200, end: 300, value: carol)
                    try! rangeDB.del(start: 0, end: 300)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 100, end: 300)

                    expect(ranges.count).to(equal(0))
                }
            }

            context("update range") {
                it("should update ranges") {
                    try! rangeDB.put(start: 0, end: 300, value: alice)
                    try! rangeDB.put(start: 100, end: 200, value: bob)
                    let ranges = try! rangeDB.get(valueType: String.self, start: 0, end: 300)

                    expect(ranges.count).to(equal(3))

                    expect(ranges[0].start).to(equal(0))
                    expect(ranges[0].end).to(equal(100))
                    expect(ranges[0].value).to(equal(alice))

                    expect(ranges[1].start).to(equal(100))
                    expect(ranges[1].end).to(equal(200))
                    expect(ranges[1].value).to(equal(bob))

                    expect(ranges[2].start).to(equal(200))
                    expect(ranges[2].end).to(equal(300))
                    expect(ranges[2].value).to(equal(alice))
                }
            }
        }
    }
}
