//
//  AddressTree.swift
//  Kushiro
//
//  Created by Koray Koska on 28.12.19.
//

import Foundation
import Web3

public class AddressTreeNode: MerkleTreeNode {

    public typealias T = EthereumAddress

    public let address: EthereumAddress

    public let data: Data

    public enum Error: Swift.Error {

        case dataLength(message: String)
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
        // Force unwrap is ok because of .utf8 encoding
        // see: https://www.objc.io/blog/2018/02/13/string-to-data-and-back/
        encoding.append(contentsOf: address.hex(eip55: false).data(using: .utf8)!)

        return encoding
    }
}

public typealias AddressTreeInclusionProof = InclusionProof<AddressTreeNode>
