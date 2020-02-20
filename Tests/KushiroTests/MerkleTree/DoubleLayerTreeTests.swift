//
//  DoubleLayerTreeTests.swift
//  KushiroTests
//
//  Created by Koray Koska on 19.02.20.
//

import XCTest
import Quick
import Nimble
import Web3
import CryptoSwift
@testable import Kushiro

final class DoubleLayerTreeTests: QuickSpec {

    override func spec() {
        describe("double layer tree tests") {

            let keccak = SHA3(variant: .keccak256)

            let token0 = try! EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false)
            let token1 = try! EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false)

            let leaf0 = DoubleLayerTreeLeaf(
                address: token0,
                start: 0,
                data: Data(keccak.calculate(for: [UInt8]("leaf0".data(using: .utf8)!)))
            )
            let leaf1 = DoubleLayerTreeLeaf(
                address: token0,
                start: 7,
                data: Data(keccak.calculate(for: [UInt8]("leaf1".data(using: .utf8)!)))
            )
            let leaf2 = DoubleLayerTreeLeaf(
                address: token0,
                start: 15,
                data: Data(keccak.calculate(for: [UInt8]("leaf2".data(using: .utf8)!)))
            )
            let leaf3 = DoubleLayerTreeLeaf(
                address: token0,
                start: 5000,
                data: Data(keccak.calculate(for: [UInt8]("leaf3".data(using: .utf8)!)))
            )
            let leaf10 = DoubleLayerTreeLeaf(
                address: token1,
                start: 100,
                data: Data(keccak.calculate(for: [UInt8]("token1leaf0".data(using: .utf8)!)))
            )
            let leaf11 = DoubleLayerTreeLeaf(
                address: token1,
                start: 200,
                data: Data(keccak.calculate(for: [UInt8]("token1leaf1".data(using: .utf8)!)))
            )

            context("double layer tree generator") {
                it("should throw returning the tree") {
                    expect {
                        try generateDoubleLayerTree(leaves: [])
                    }.to(throwError(DoubleLayerTree.Error.leavesEmpty))
                }
            }

            context("get root") {
                it("should throw the exception invalid data length") {
                    let invalidLeaf = DoubleLayerTreeLeaf(
                        address: token0,
                        start: 500,
                        data: "leaf0".data(using: .utf8)!
                    )
                    expect {
                        try DoubleLayerTree(leaves: [leaf0, leaf1, leaf2, invalidLeaf])
                    }.to(throwError(IntervalTreeNode.Error.dataLength(message: "data length is not 32 bytes")))
                }
            }
        }
    }
}
