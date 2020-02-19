//
//  IntervalTree.swift
//  Kushiro
//
//  Created by Koray Koska on 17.01.20.
//

import Foundation
import Web3
import CryptoSwift
import BigInt

public class IntervalTreeNode: MerkleTreeNode {

    public typealias T = BigInt

    public let start: BigInt

    public let data: Data

    public enum Error: Swift.Error {

        case dataLength(message: String)
    }

    public static func decode(data: Data) throws -> IntervalTreeNode {
        // TODO: This seems like total garbage to me. But its 02:17 so please check this again...
        //       --- (the hash of the address is 20 bytes right? or even dynamic for non ethereum?)
        // 32 bytes in hex are 64 characters (bytes), which is the max we allow right now. plus 32 bytes hash
        guard data.count > 32 else {
            throw Error.dataLength(message: "bytes are not more than 32 bytes")
        }
        let rawBytes = [UInt8](data)

        let start = BigInt(String(data: Data(Array(rawBytes[32...])), encoding: .utf8) ?? "", radix: 16) ?? 0

        return try IntervalTreeNode(start: start, data: Data(Array(rawBytes[0..<32])))
    }

    ///
    /// Creates a new instance of `IntervalTreeNode` with the given lower bound of range and hash of the leaf data.
    ///
    /// Data has to be exactly 32 bytes.
    ///
    /// - parameter start: 32 byte integer and lower bound of range
    /// - parameter data: Hash of the leaf data.
    ///
    /// - throws: `Error.dataLength(message:)` if data is not exactly 32 bytes long
    public init(start: BigInt, data: Data) throws {
        if data.count != 32 {
            throw Error.dataLength(message: "data length is not 32 bytes")
        }

        self.start = start
        self.data = data
    }

    public func getInterval() -> BigInt {
        return start
    }

    public func encode() -> Data {
        var encoding = data
        // Force unwrap is ok because of .utf8 encoding
        // see: https://www.objc.io/blog/2018/02/13/string-to-data-and-back/
        encoding.append(String(start, radix: 16).lowercased().paddingLeft(toLength: 64, withPad: "0").hexDecodedData())

        return encoding
    }
}

extension IntervalTreeNode: Equatable {

    public static func == (lhs: IntervalTreeNode, rhs: IntervalTreeNode) -> Bool {
        return lhs.start == rhs.start && lhs.data == rhs.data
    }
}

public typealias IntervalTreeInclusionProof = InclusionProof<BigInt, IntervalTreeNode>

public class IntervalTree: GenericMerkleTree {

    public typealias I = BigInt

    public typealias B = BigInt

    public typealias T = IntervalTreeNode

    public typealias Verifier = IntervalTreeVerifier

    public var levels: [[IntervalTreeNode]] = []

    public let leaves: [IntervalTreeNode]

    public let verifier: IntervalTreeVerifier

    public required init(leaves: [IntervalTreeNode], verifier: IntervalTreeVerifier = IntervalTreeVerifier()) throws {
        self.leaves = leaves
        self.verifier = verifier

        // TODO: Pls change this :(
        var this = self
        try this.calculateRoot(leaves: leaves, level: 0)
        self.levels = this.levels
    }

    public func getLeaves(start: BigInt, end: BigInt) -> [Int] {
        var results = [Int]()
        for i in 0..<leaves.count {
            let l = leaves[i]

            let targetStart = l.start
            let targetEnd = leaves[safe: i + 1]?.start ?? BigInt.max256Bit

            let maxStart = max(targetStart, start)
            let maxEnd = max(targetEnd, end)

            if maxStart < maxEnd {
                results.append(i)
            }
        }

        return results
    }
}

public class IntervalTreeVerifier: GenericMerkleVerifier {

    public enum Error: Swift.Error {

        case leftStartGreaterThanRightStart(message: String)
    }

    public typealias B = BigInt

    public typealias T = IntervalTreeNode

    public init() {
    }

    public func computeParent(a: IntervalTreeNode, b: IntervalTreeNode) throws -> IntervalTreeNode {
        if a.start > b.start {
            throw Error.leftStartGreaterThanRightStart(message: "left.start is not less than right.start")
        }

        var toHash = a.encode()
        toHash.append(b.encode())
        let hash = SHA3(variant: hashAlgorithm).calculate(for: [UInt8](toHash))

        // Force unwrapping is ok as our hash call above must return 32 bytes
        return try! IntervalTreeNode(start: b.start, data: Data(hash))
    }

    public func createEmptyNode() -> IntervalTreeNode {
        let hash = SHA3(variant: hashAlgorithm).calculate(for: [UInt8]())
        return try! IntervalTreeNode(start: BigInt.max256Bit, data: Data(hash))
    }
}
