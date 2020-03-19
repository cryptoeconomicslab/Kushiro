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

                it("should return merkle root") {
                    let tree = try! DoubleLayerTree(leaves: [leaf0, leaf1, leaf2])
                    let root = tree.getRoot()

                    expect(root.hexEncodedString()).to(equal("3ec5a3c49278e6d89a313d2f8716b1cf62534f3c31fdcade30809fd90ee47368"))
                }

                it("should return merkle root with leaves that belongs to multiple address") {
                    let tree = try! DoubleLayerTree(leaves: [leaf0, leaf1, leaf2, leaf3, leaf10, leaf11])
                    let root = tree.getRoot()

                    expect(root.toHexString()).to(equal("1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f"))
                }
            }

            context("get inclusion proof") {
                it("should return the inclusion proof") {
                    let tree = try! DoubleLayerTree(leaves: [leaf0, leaf1, leaf2, leaf3, leaf10, leaf11])
                    let inclusionProof0 = tree.getInclusionProofByAddressAndIndex(address: token0, index: 0)
                    let inclusionProof1 = tree.getInclusionProofByAddressAndIndex(address: token0, index: 1)

                    try! expect(inclusionProof0).to(equal(DoubleLayerInclusionProof(
                        intervalInclusionProof: IntervalTreeInclusionProof(
                            leafIndex: 0,
                            leafPosition: 0,
                            siblings: [
                                IntervalTreeNode(
                                    start: 7,
                                    data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 5000,
                                    data: "ef583c07cae62e3a002a9ad558064ae80db17162801132f9327e8bb6da16ea8a".hexDecodedData()
                                )
                            ]
                        ),
                        addressInclusionProof: AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                                )
                            ]
                        )
                    )))

                    try! expect(inclusionProof1).to(equal(DoubleLayerInclusionProof(
                        intervalInclusionProof: IntervalTreeInclusionProof(
                            leafIndex: 7,
                            leafPosition: 1,
                            siblings: [
                                IntervalTreeNode(
                                    start: 0,
                                    data: "6fef85753a1881775100d9b0a36fd6c333db4e7f358b8413d3819b6246b66a30".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 5000,
                                    data: "ef583c07cae62e3a002a9ad558064ae80db17162801132f9327e8bb6da16ea8a".hexDecodedData()
                                )
                            ]
                        ),
                        addressInclusionProof: AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                                )
                            ]
                        )
                    )))
                }
            }

            context("verify inclusion") {
                let validInclusionProofFor0 = try! DoubleLayerInclusionProof(
                    intervalInclusionProof: IntervalTreeInclusionProof(
                        leafIndex: 0,
                        leafPosition: 0,
                        siblings: [
                            IntervalTreeNode(
                                start: 7,
                                data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                            ),
                            IntervalTreeNode(
                                start: 5000,
                                data: "ef583c07cae62e3a002a9ad558064ae80db17162801132f9327e8bb6da16ea8a".hexDecodedData()
                            )
                        ]
                    ),
                    addressInclusionProof: AddressTreeInclusionProof(
                        leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                        leafPosition: 0,
                        siblings: [
                            AddressTreeNode(
                                address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                            )
                        ]
                    )
                )

                it("should return true") {
                    let verifier = DoubleLayerTreeVerifier()
                    let root = "1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f".hexDecodedData()
                    let result = try! verifier.verifyInclusion(
                        leaf: leaf0,
                        range: 0..<7,
                        root: root,
                        inclusionProof: validInclusionProofFor0
                    )

                    expect(result).to(beTrue())
                }

                it("should return true for 2") {
                    let verifier = DoubleLayerTreeVerifier()
                    let root = "1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f".hexDecodedData()

                    let validInclusionProofFor2 = try! DoubleLayerInclusionProof(
                        intervalInclusionProof: IntervalTreeInclusionProof(
                            leafIndex: 15,
                            leafPosition: 2,
                            siblings: [
                                IntervalTreeNode(
                                    start: 5000,
                                    data: "fdd1f2a1ec75fe968421a41d2282200de6bec6a21f81080a71b1053d9c0120f3".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 7,
                                    data: "59a76952828fd54de12b708bf0030e055ae148c0a5a7d8b4f191d519275337e8".hexDecodedData()
                                )
                            ]
                        ),
                        addressInclusionProof: AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                                )
                            ]
                        )
                    )

                    let result = try! verifier.verifyInclusion(
                        leaf: leaf2,
                        range: 15..<20,
                        root: root,
                        inclusionProof: validInclusionProofFor2
                    )

                    expect(result).to(beTrue())
                }

                it("should return false with invalid proof") {
                    let verifier = DoubleLayerTreeVerifier()
                    let root = "1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f".hexDecodedData()

                    expect {
                        try verifier.verifyInclusion(
                            leaf: leaf1,
                            range: 0..<7,
                            root: root,
                            inclusionProof: validInclusionProofFor0
                        )
                    }.to(throwError(DoubleLayerTreeVerifier.Error.rangeExceedsImplicitRange))
                }

                it("should throw an exception when detecting an intersection") {
                    let verifier = DoubleLayerTreeVerifier()
                    let root = "1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f".hexDecodedData()

                    let invalidInclusionProof = try! DoubleLayerInclusionProof(
                        intervalInclusionProof: IntervalTreeInclusionProof(
                            leafIndex: 0,
                            leafPosition: 0,
                            siblings: [
                                IntervalTreeNode(
                                    start: 7,
                                    data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 0,
                                    data: "ef583c07cae62e3a002a9ad558064ae80db17162801132f9327e8bb6da16ea8a".hexDecodedData()
                                )
                            ]
                        ),
                        addressInclusionProof: AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                                )
                            ]
                        )
                    )

                    expect {
                        try verifier.verifyInclusion(
                            leaf: leaf0,
                            range: 0..<7,
                            root: root,
                            inclusionProof: invalidInclusionProof
                        )
                    }.to(throwError(GenericMerkleVerifierError.invalidIntersection(message: "invalid InclusionProof, intersection detected")))
                }

                it("should throw an exception if left.start is not less than right.start") {
                    let verifier = DoubleLayerTreeVerifier()
                    let root = "1aa3429d5aa7bf693f3879fdfe0f1a979a4b49eaeca9638fea07ad7ee5f0b64f".hexDecodedData()

                    let invalidInclusionProof = try! DoubleLayerInclusionProof(
                        intervalInclusionProof: IntervalTreeInclusionProof(
                            leafIndex: 7,
                            leafPosition: 1,
                            siblings: [
                                IntervalTreeNode(
                                    start: 0,
                                    data: "6fef85753a1881775100d9b0a36fd6c333db4e7f358b8413d3819b6246b66a30".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 0,
                                    data: "ef583c07cae62e3a002a9ad558064ae80db17162801132f9327e8bb6da16ea8a".hexDecodedData()
                                )
                            ]
                        ),
                        addressInclusionProof: AddressTreeInclusionProof(
                            leafIndex: EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
                            leafPosition: 0,
                            siblings: [
                                AddressTreeNode(
                                    address: EthereumAddress(hex: "0x0000000000000000000000000000000000000001", eip55: false),
                                    data: "dd779be20b84ced84b7cbbdc8dc98d901ecd198642313d35d32775d75d916d3a".hexDecodedData()
                                )
                            ]
                        )
                    )

                    expect {
                        try verifier.verifyInclusion(
                            leaf: leaf1,
                            range: 7..<15,
                            root: root,
                            inclusionProof: invalidInclusionProof
                        )
                    }.to(throwError(IntervalTreeVerifier.Error.leftStartGreaterThanRightStart(message: "left.start is not less than right.start")))
                }
            }

            context("get leaves") {
                it("should return the leaves") {
                    let tree = try! DoubleLayerTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let leaves = tree.getLeaves(address: token0, start: 0, end: 100)

                    expect(leaves.count).to(equal(3))
                }

                it("should return the leaves within partially") {
                    let tree = try! DoubleLayerTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let leaves = tree.getLeaves(address: token0, start: 5, end: 100)

                    expect(leaves.count).to(equal(3))
                }
            }
        }
    }
}
