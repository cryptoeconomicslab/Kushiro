//
//  RangeRecordTests.swift
//  KushiroTests
//
//  Created by Koray Koska on 02.12.19.
//

import XCTest
import Quick
import Nimble
@testable import Kushiro

final class RangeRecordTests: QuickSpec {

    override func spec() {
        describe("range record tests") {

            let testValue = "value"

            context("intersect") {

                it("does not intersect for [0-50) and [100-200)") {
                    let rangeRecord = RangeRecord(start: 0, end: 50, value: testValue)
                    expect(rangeRecord.intersects(start: 100, end: 200)).to(beFalse())
                }

                it("does not intersect for [0-100) and [100-200)") {
                    let rangeRecord = RangeRecord(start: 0, end: 100, value: testValue)
                    expect(rangeRecord.intersects(start: 100, end: 200)).to(beFalse())
                }

                it("intersects for [0-150) and [100-200)") {
                    let rangeRecord = RangeRecord(start: 0, end: 150, value: testValue)
                    expect(rangeRecord.intersects(start: 100, end: 200)).to(beTrue())
                }

                it("intersects for [0-300) and [100-200)") {
                    let rangeRecord = RangeRecord(start: 0, end: 300, value: testValue)
                    expect(rangeRecord.intersects(start: 100, end: 200)).to(beTrue())
                }

                it("intersects for same ranges") {
                    let rangeRecord = RangeRecord(start: 0, end: 100, value: testValue)
                    expect(rangeRecord.intersects(start: 0, end: 100)).to(beTrue())
                }

                it("does not intersect for [100-200) and [0-50)") {
                    let rangeRecord = RangeRecord(start: 100, end: 200, value: testValue)
                    expect(rangeRecord.intersects(start: 0, end: 50)).to(beFalse())
                }

                it("does not intersect for [100-200) and [0-100)") {
                    let rangeRecord = RangeRecord(start: 100, end: 200, value: testValue)
                    expect(rangeRecord.intersects(start: 0, end: 100)).to(beFalse())
                }

                it("intersects for [100-200) and [0-150)") {
                    let rangeRecord = RangeRecord(start: 100, end: 200, value: testValue)
                    expect(rangeRecord.intersects(start: 0, end: 150)).to(beTrue())
                }

                it("intersects for [100-200) and [0-300)") {
                    let rangeRecord = RangeRecord(start: 100, end: 200, value: testValue)
                    expect(rangeRecord.intersects(start: 0, end: 300)).to(beTrue())
                }
            }
        }
    }
}
