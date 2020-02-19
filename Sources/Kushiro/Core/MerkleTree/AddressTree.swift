//
//  AddressTree.swift
//  Kushiro
//
//  Created by Koray Koska on 28.12.19.
//

import Foundation
import Web3
import CryptoSwift

public class AddressTreeNode: MerkleTreeNode {

    // TODO: We should use a more abstract Address type here. Not EthereumAddress.
    public typealias T = EthereumAddress

    public let address: EthereumAddress

    public let data: Data

    public enum Error: Swift.Error {

        case dataLength(message: String)
    }

    public static func decode(data: Data) throws -> AddressTreeNode {
        guard data.count > 32 else {
            throw Error.dataLength(message: "bytes are not more than 32 bytes")
        }
        let rawBytes = [UInt8](data)

        let address = try EthereumAddress(Array(rawBytes[32...]))

        return try AddressTreeNode(address: address, data: Data(Array(rawBytes[0..<32])))
    }

    /// Creates a new instance of `AddressTreeNode` with the given address and data.
    ///
    /// Data has to be exactly 32 bytes.
    ///
    /// - parameter address: The Ethereum address
    /// - parameter data: The data (exactly 32 bytes)
    ///
    /// - throws: `Error.dataLength(message:)` if data is not exactly 32 bytes long
    public init(address: EthereumAddress, data: Data) throws {
        if data.count != 32 {
            throw Error.dataLength(message: "data length is not 32 bytes")
        }

        self.address = address
        self.data = data
    }

    public func getInterval() -> EthereumAddress {
        return address
    }

    public func encode() -> Data {
        var encoding = data
        encoding.append(contentsOf: address.rawAddress)

        return encoding
    }
}

extension AddressTreeNode: Equatable {

    public static func == (lhs: AddressTreeNode, rhs: AddressTreeNode) -> Bool {
        return lhs.address == rhs.address && lhs.data == rhs.data
    }
}

public typealias AddressTreeInclusionProof = InclusionProof<EthereumAddress, AddressTreeNode>

public class AddressTree: GenericMerkleTree {

    public typealias I = EthereumAddress

    public typealias B = EthereumAddress

    public typealias T = AddressTreeNode

    public typealias Verifier = AddressTreeVerifier

    public var levels: [[AddressTreeNode]] = []

    public let leaves: [AddressTreeNode]

    public let verifier: AddressTreeVerifier

    public required init(leaves: [AddressTreeNode], verifier: AddressTreeVerifier = AddressTreeVerifier()) throws {
        self.leaves = leaves
        self.verifier = verifier

        // TODO: Pls change this :(
        var this = self
        try this.calculateRoot(leaves: leaves, level: 0)
        self.levels = this.levels
    }

    public func getIndexByAddress(address: EthereumAddress) -> Int? {
        let index = leaves.firstIndex { l in
            return l.address.rawAddress == address.rawAddress
        }

        return index
    }
}

public class AddressTreeVerifier: GenericMerkleVerifier {

    public typealias B = EthereumAddress

    public typealias T = AddressTreeNode

    public init() {
    }

    public func computeParent(a: AddressTreeNode, b: AddressTreeNode) -> AddressTreeNode {
        var toHash = a.encode()
        toHash.append(b.encode())
        let hash = SHA3(variant: hashAlgorithm).calculate(for: [UInt8](toHash))

        // Force unwrapping is ok as our hash call above must return 32 bytes
        return try! AddressTreeNode(address: a.address, data: Data(hash))
    }

    public func createEmptyNode() -> AddressTreeNode {
        // TODO: empty node shouldn't be zero address?
        return try! AddressTreeNode(address: EthereumAddress([UInt8](repeating: 0, count: 20)), data: Data([UInt8](repeating: 0, count: 32)))
    }
}

// TODO: Check this

extension EthereumAddress: Comparable {

    public static func < (lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.customHex() < rhs.customHex()
    }
}
