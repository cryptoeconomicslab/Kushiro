//
//  AddressTreeTests.swift
//  Kushiro
//
//  Created by Koray Koska on 17.01.20.
//

import XCTest
import Quick
import Nimble
import Web3
import CryptoSwift
@testable import Kushiro

final class AddressTreeTests: QuickSpec {

    override func spec() {
        describe("address tree tests") {

            let leaf0 = try! AddressTreeNode(
                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("root0".data(using: .utf8)!)))
            )
            let leaf1 = try! AddressTreeNode(
                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("root1".data(using: .utf8)!)))
            )
            let leaf2 = try! AddressTreeNode(
                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000002", eip55: false),
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("root2".data(using: .utf8)!)))
            )
            let leaf3 = try! AddressTreeNode(
                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000003", eip55: false),
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("root3".data(using: .utf8)!)))
            )

            context("get root") {
                it("should return the merkle root") {
                    let tree = try! AddressTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let root = tree.getRoot()

                    expect(root.hexEncodedString()).to(equal("30acf9f99796b1b310d05d35854812ff91f43cb3f35c932c0d8053bbae3a661e"))
                }
            }

            context("get inclusion proof") {
                it("should return the inclusion proof") {
                    let tree = try! AddressTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let inclusionProof0 = tree.getInclusionProof(index: 0)
                    let inclusionProof1 = tree.getInclusionProof(index: 1)

                    try! expect(inclusionProof0).to(equal(
                        AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "99fff0297ffbd7e2f1a6820971ba8fa9d502e2a9259ff15813849b63e09af0c1".hexDecodedData()
                                ),
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000002", eip55: false),
                                    data: "350008941a274700780a1247fa6e7b2db5c34f1bfbcf15e9fb9230f6dd239ca3".hexDecodedData()
                                )
                            ]
                        )
                    ))

                    try! expect(inclusionProof1).to(equal(
                        AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                            leafPosition: 1,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                                    data: "cca51deaf7e2f905f605c563fc14ce3f5314136d90598cf77da785cf016f6a3f".hexDecodedData()
                                ),
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000002", eip55: false),
                                    data: "350008941a274700780a1247fa6e7b2db5c34f1bfbcf15e9fb9230f6dd239ca3".hexDecodedData()
                                )
                            ]
                        )
                    ))
                }
            }

            context("verify inclusion") {
                it("should return true") {
                    let tree = AddressTreeVerifier()
                    let root = "30acf9f99796b1b310d05d35854812ff91f43cb3f35c932c0d8053bbae3a661e".hexDecodedData()

                    let inclusionProof = try! AddressTreeInclusionProof(
                        leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                        leafPosition: 0,
                        siblings: [
                            AddressTreeNode(
                                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                data: "99fff0297ffbd7e2f1a6820971ba8fa9d502e2a9259ff15813849b63e09af0c1".hexDecodedData()
                            ),
                            AddressTreeNode(
                                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000002", eip55: false),
                                data: "350008941a274700780a1247fa6e7b2db5c34f1bfbcf15e9fb9230f6dd239ca3".hexDecodedData()
                            )
                        ]
                    )
                    let result = try! tree.verifyInclusion(
                        leaf: leaf0,
                        intervalStart: leaf1.address,
                        intervalEnd: leaf1.address,
                        root: root,
                        inclusionProof: inclusionProof
                    )

                    expect(result).to(beTrue())
                }
            }
        }
    }
}
