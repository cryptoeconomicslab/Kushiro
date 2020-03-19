//
//  IntervalTreeTests.swift
//  BigInt
//
//  Created by Koray Koska on 18.02.20.
//

import XCTest
import Quick
import Nimble
import Web3
import CryptoSwift
@testable import Kushiro

final class IntervalTreeTests: QuickSpec {

    override func spec() {
        describe("interval tree tests") {

            let leaf0 = try! IntervalTreeNode(
                start: 0,
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("leaf0".data(using: .utf8)!)))
            )
            let leaf1 = try! IntervalTreeNode(
                start: 7,
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("leaf1".data(using: .utf8)!)))
            )
            let leaf2 = try! IntervalTreeNode(
                start: 15,
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("leaf2".data(using: .utf8)!)))
            )
            let leaf3 = try! IntervalTreeNode(
                start: 300,
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("leaf3".data(using: .utf8)!)))
            )
            let leafBigNumber = try! IntervalTreeNode(
                start: 72943610,
                data: Data(SHA3(variant: .keccak256).calculate(for: [UInt8]("leaf4".data(using: .utf8)!)))
            )

            context("get root") {
                it("should return merkle root with odd number of leaves") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2])
                    let root = tree.getRoot()
                    expect(root.hexEncodedString()).to(equal("3ec5a3c49278e6d89a313d2f8716b1cf62534f3c31fdcade30809fd90ee47368"))
                }

                it("should return merkle root with even number of leaves") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let root = tree.getRoot()
                    expect(root.hexEncodedString()).to(equal("95703b48a33f3750929082600d9bdd890ffef2b8434c19607a741f0dcc8a70c8"))
                }

                it("should return merkle root with leaf which has big number as start") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2, leaf3, leafBigNumber])
                    let root = tree.getRoot()
                    expect(root.hexEncodedString()).to(equal("714ab06047e0791228efb82d081deb2a011079b58db69c409771499c59292798"))
                }
            }

            context("get inclusion proof") {
                it("should return the inclusion proof") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2])
                    let inclusionProof0 = tree.getInclusionProof(index: 0)
                    let inclusionProof1 = tree.getInclusionProof(index: 1)

                    try! expect(inclusionProof0).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 0,
                            leafPosition: 0,
                            siblings: [
                                IntervalTreeNode(
                                    start: 7,
                                    data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: BigInt.max256Bit,
                                    data: "e99f92621ea9ca2e0709f58dc56c139ecf076c388952df2b5cd7a6ca1ae2df5c".hexDecodedData()
                                )
                            ]
                        )
                    ))

                    try! expect(inclusionProof1).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 7,
                            leafPosition: 1,
                            siblings: [
                                IntervalTreeNode(
                                    start: 0,
                                    data: "6fef85753a1881775100d9b0a36fd6c333db4e7f358b8413d3819b6246b66a30".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: BigInt.max256Bit,
                                    data: "e99f92621ea9ca2e0709f58dc56c139ecf076c388952df2b5cd7a6ca1ae2df5c".hexDecodedData()
                                )
                            ]
                        )
                    ))
                }

                it("should return inclusionproof with even number of leaves") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2, leaf3])
                    let inclusionProof0 = tree.getInclusionProof(index: 0)
                    let inclusionProof1 = tree.getInclusionProof(index: 1)
                    let inclusionProof2 = tree.getInclusionProof(index: 2)
                    let inclusionProof3 = tree.getInclusionProof(index: 3)

                    try! expect(inclusionProof0).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 0,
                            leafPosition: 0,
                            siblings: [
                                IntervalTreeNode(
                                    start: 7,
                                    data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 300,
                                    data: "3b93a2a95fbcfbefdd3b6604f965379833a263fb74913f970b201fb7e1d5949e".hexDecodedData()
                                )
                            ]
                        )
                    ))

                    try! expect(inclusionProof1).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 7,
                            leafPosition: 1,
                            siblings: [
                                IntervalTreeNode(
                                    start: 0,
                                    data: "6fef85753a1881775100d9b0a36fd6c333db4e7f358b8413d3819b6246b66a30".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 300,
                                    data: "3b93a2a95fbcfbefdd3b6604f965379833a263fb74913f970b201fb7e1d5949e".hexDecodedData()
                                )
                            ]
                        )
                    ))

                    try! expect(inclusionProof2).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 15,
                            leafPosition: 2,
                            siblings: [
                                IntervalTreeNode(
                                    start: 300,
                                    data: "fdd1f2a1ec75fe968421a41d2282200de6bec6a21f81080a71b1053d9c0120f3".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 7,
                                    data: "59a76952828fd54de12b708bf0030e055ae148c0a5a7d8b4f191d519275337e8".hexDecodedData()
                                )
                            ]
                        )
                    ))

                    try! expect(inclusionProof3).to(equal(
                        IntervalTreeInclusionProof(
                            leafIndex: 300,
                            leafPosition: 3,
                            siblings: [
                                IntervalTreeNode(
                                    start: 15,
                                    data: "ba620d61dac4ddf2d7905722b259b0bd34ec4d37c5796d9a22537c54b3f972d8".hexDecodedData()
                                ),
                                IntervalTreeNode(
                                    start: 7,
                                    data: "59a76952828fd54de12b708bf0030e055ae148c0a5a7d8b4f191d519275337e8".hexDecodedData()
                                )
                            ]
                        )
                    ))
                }
            }

            context("verify inclusion") {
                let verifier = IntervalTreeVerifier()

                it("should return true") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2])
                    let root = tree.getRoot()
                    let inclusionProof = tree.getInclusionProof(index: 0)
                    let result = try! verifier.verifyInclusion(
                        leaf: leaf0,
                        intervalStart: leaf0.start,
                        intervalEnd: leaf0.start,
                        root: root,
                        inclusionProof: inclusionProof
                    )

                    expect(result).to(beTrue())
                }

                it("should return true with even number of leaves") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2, leafBigNumber])
                    let root = tree.getRoot()

                    let inclusionProof0 = tree.getInclusionProof(index: 0)
                    let inclusionProof1 = tree.getInclusionProof(index: 1)
                    let inclusionProof2 = tree.getInclusionProof(index: 2)
                    let inclusionProof3 = tree.getInclusionProof(index: 3)

                    let result0 = try! verifier.verifyInclusion(
                        leaf: leaf0,
                        intervalStart: leaf0.start,
                        intervalEnd: leaf1.start,
                        root: root,
                        inclusionProof: inclusionProof0
                    )
                    expect(result0).to(beTrue())

                    let result1 = try! verifier.verifyInclusion(
                        leaf: leaf1,
                        intervalStart: leaf1.start,
                        intervalEnd: leaf2.start,
                        root: root,
                        inclusionProof: inclusionProof1
                    )
                    expect(result1).to(beTrue())

                    let result2 = try! verifier.verifyInclusion(
                        leaf: leaf2,
                        intervalStart: leaf2.start,
                        intervalEnd: leaf3.start,
                        root: root,
                        inclusionProof: inclusionProof2
                    )
                    expect(result2).to(beTrue())

                    let result3 = try! verifier.verifyInclusion(
                        leaf: leafBigNumber,
                        intervalStart: leafBigNumber.start,
                        intervalEnd: leafBigNumber.start + 1,
                        root: root,
                        inclusionProof: inclusionProof3
                    )
                    expect(result3).to(beTrue())
                }

                it("should return false with invalid leaf") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2, leafBigNumber])
                    let root = tree.getRoot()
                    let inclusionProof0 = tree.getInclusionProof(index: 0)
                    let result0 = try! verifier.verifyInclusion(
                        leaf: leaf1,
                        intervalStart: leaf1.start,
                        intervalEnd: leaf1.start,
                        root: root,
                        inclusionProof: inclusionProof0
                    )
                    expect(result0).to(beFalse())
                }

                it("should throw an exception when detecting intersections") {
                    let root = "91d07b5d34a03ce1831ff23c6528d2cbf64adc24e3321373dc616a6740b02577".hexDecodedData()
                    let invalidInclusionProof = try! IntervalTreeInclusionProof(
                        leafIndex: 0,
                        leafPosition: 0,
                        siblings: [
                            IntervalTreeNode(
                                start: 7,
                                data: "036491cc10808eeb0ff717314df6f19ba2e232d04d5f039f6fa382cae41641da".hexDecodedData()
                            ),
                            IntervalTreeNode(
                                start: 0,
                                data: "4670e484ff31d2ec8471b1f8a1e1cb8dc104b3a4b766ae0b7c2c604a34cb530e".hexDecodedData()
                            )
                        ]
                    )

                    expect {
                        try verifier.verifyInclusion(
                            leaf: leaf0,
                            intervalStart: leaf0.start,
                            intervalEnd: leaf1.start,
                            root: root,
                            inclusionProof: invalidInclusionProof
                        )
                    }.to(throwError(GenericMerkleVerifierError.invalidIntersection(message: "invalid InclusionProof, intersection detected")))
                }

                it("should throw an exception left.start is not less than right.start") {
                    let root = "91d07b5d34a03ce1831ff23c6528d2cbf64adc24e3321373dc616a6740b02577".hexDecodedData()
                    let invalidInclusionProof = try! IntervalTreeInclusionProof(
                        leafIndex: 7,
                        leafPosition: 1,
                        siblings: [
                            IntervalTreeNode(
                                start: 0,
                                data: "6fef85753a1881775100d9b0a36fd6c333db4e7f358b8413d3819b6246b66a30".hexDecodedData()
                            ),
                            IntervalTreeNode(
                                start: 0,
                                data: "4670e484ff31d2ec8471b1f8a1e1cb8dc104b3a4b766ae0b7c2c604a34cb530e".hexDecodedData()
                            )
                        ]
                    )

                    expect {
                        try verifier.verifyInclusion(
                            leaf: leaf1,
                            intervalStart: leaf1.start,
                            intervalEnd: leaf2.start,
                            root: root,
                            inclusionProof: invalidInclusionProof
                        )
                    }.to(throwError(IntervalTreeVerifier.Error.leftStartGreaterThanRightStart(message: "left.start is not less than right.start")))
                }
            }

            context("get leaves") {
                it("should return the leaves") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2])
                    let leaves = tree.getLeaves(start: 0, end: 100)
                    expect(leaves.count).to(equal(3))
                }
                it("should return the leaves within partially") {
                    let tree = try! IntervalTree(leaves: [leaf0, leaf1, leaf2])
                    let leaves = tree.getLeaves(start: 5, end: 100)
                    expect(leaves.count).to(equal(3))
                }
            }
        }
    }
}
