//
//  DoubleLayerTree.swift
//  Kushiro
//
//  Created by Koray Koska on 17.01.20.
//

import Foundation
import Web3

public struct DoubleLayerInclusionProof: Equatable {

    let intervalInclusionProof: IntervalTreeInclusionProof

    let addressInclusionProof: AddressTreeInclusionProof

    public init(intervalInclusionProof: IntervalTreeInclusionProof, addressInclusionProof: AddressTreeInclusionProof) {
        self.intervalInclusionProof = intervalInclusionProof
        self.addressInclusionProof = addressInclusionProof
    }
}

public struct DoubleLayerInterval {

    let start: BigInt

    let address: EthereumAddress

    public init(start: BigInt, address: EthereumAddress) {
        self.start = start
        self.address = address
    }
}

public class DoubleLayerTreeLeaf: MerkleTreeNode {

    public typealias T = DoubleLayerInterval

    public let address: EthereumAddress

    public let start: BigInt

    public let data: Data

    public init(address: EthereumAddress, start: BigInt, data: Data) {
        self.address = address
        self.start = start
        self.data = data
    }

    public func encode() -> Data {
        var encoding = data
        // Force unwrap is ok because of .utf8 encoding
        // see: https://www.objc.io/blog/2018/02/13/string-to-data-and-back/
        encoding.append(contentsOf: address.customHex().data(using: .utf8)!)

        return encoding
    }

    public func getInterval() -> DoubleLayerInterval {
        return DoubleLayerInterval(start: start, address: address)
    }
}

/// Can be used as a `MerkleTreeGenerator<DoubleLayerInterval, DoubleLayerTreeLeaf>`
public func generateDoubleLayerTree(leaves: [DoubleLayerTreeLeaf]) throws -> DoubleLayerTree {
    return try DoubleLayerTree(leaves: leaves)
}

/**
 * DoubleLayerTree class
 *     This class construct double layer tree which has 2 layers.
 *     The 1st layer is address tree and 2nd layer is interval tree.
 *     Please see https://docs.plasma.group/projects/spec/en/latest/src/01-core/double-layer-tree.html
 *
 */
public class DoubleLayerTree: MerkleTreeProtocol {

    public enum Error: Swift.Error {

        case leavesEmpty
    }

    public typealias I = DoubleLayerInterval

    public typealias T = DoubleLayerTreeLeaf

    public let addressTree: AddressTree

    public private(set) var intervalTreeMap: [String: IntervalTree] = [:]

    private let leaves: [DoubleLayerTreeLeaf]

    public init(leaves: [DoubleLayerTreeLeaf]) throws {
        if leaves.count == 0 {
            throw Error.leavesEmpty
        }

        self.leaves = leaves

        var addressTreeLeaves = [AddressTreeNode]()

        let addressLeavesMap = try leaves.reduce([] as [(key: String, value: [IntervalTreeNode])]) { result, leaf in
            var result = result

            let addressStr = leaf.address.customHex()

            let mapIndex = result.firstIndex(where: { $0.key == addressStr })
            var map = mapIndex != nil ? result[mapIndex!].value : []
            map.append(try IntervalTreeNode(start: leaf.start, data: leaf.data))

            if let mapIndex = mapIndex {
                result[mapIndex] = (key: addressStr, value: map)
            } else {
                result.append((key: addressStr, value: map))
            }

            return result
        }

        for (key, value) in addressLeavesMap {
            let intervalTree = try IntervalTree(leaves: value)
            self.intervalTreeMap[key] = intervalTree

            addressTreeLeaves.append(
                try AddressTreeNode(address: EthereumAddress(hex: key, eip55: false), data: intervalTree.getRoot())
            )
        }

        self.addressTree = try AddressTree(leaves: addressTreeLeaves)
    }

    public func getRoot() -> Data {
        return addressTree.getRoot()
    }

    public func findIndex(leaf: Data) -> Int? {
        let index = leaves.firstIndex { l in
            return l.data == leaf
        }

        return index
    }

    public func getLeaf(index: Int) -> DoubleLayerTreeLeaf {
        fatalError("not implemented")
    }

    public func getLeaves(address: EthereumAddress, start: BigInt, end: BigInt) -> [Int] {
        let tree = intervalTreeMap[address.customHex()]

        return tree?.getLeaves(start: start, end: end) ?? []
    }

    public func getInclusionProofByAddressAndIndex(address: EthereumAddress, index: Int) -> DoubleLayerInclusionProof? {
        if let addressTreeIndex = addressTree.getIndexByAddress(address: address), let intervalTree = intervalTreeMap[address.customHex()] {
            let addressInclusionProof = addressTree.getInclusionProof(index: addressTreeIndex)
            let intervalInclusionProof = intervalTree.getInclusionProof(index: index)

            return DoubleLayerInclusionProof(intervalInclusionProof: intervalInclusionProof, addressInclusionProof: addressInclusionProof)
        }

        return nil
    }
}

/**
 * DoubleLayerTreeVerifier is the class to verify inclusion of Double Layer Tree.
 */
public class DoubleLayerTreeVerifier {

    public enum Error: Swift.Error {

        case rangeExceedsImplicitRange
    }

    ///
    /// verifyInclusion verify leaf data is included or not in specific range.
    ///
    /// - parameter leaf: The leaf to verify
    /// - parameter range: The range to verify it within implicit range
    /// - parameter root: The merkle root of tree
    /// - parameter inclusionProof: proof data to verify inclusion
    public func verifyInclusion(
        leaf: DoubleLayerTreeLeaf,
        range: Range<Int>,
        root: Data,
        inclusionProof: DoubleLayerInclusionProof
    ) throws -> Bool {
        let intervalTreeVerifier = IntervalTreeVerifier()
        let addressTreeVerifier = AddressTreeVerifier()

        let intervalNode = try IntervalTreeNode(start: leaf.start, data: leaf.data)

        let merklePath = intervalTreeVerifier.calculateMerklePath(inclusionProof: inclusionProof.intervalInclusionProof)
        let computeIntervalRootAndEnd = try intervalTreeVerifier.computeRootFromInclusionProof(
            leaf: intervalNode,
            merklePath: merklePath,
            proofElement: inclusionProof.intervalInclusionProof.siblings
        )

        if computeIntervalRootAndEnd.implicitEnd < range.upperBound || range.lowerBound < leaf.start {
            throw Error.rangeExceedsImplicitRange
        }

        return try addressTreeVerifier.verifyInclusion(
            leaf: AddressTreeNode(address: leaf.address, data: computeIntervalRootAndEnd.root),
            intervalStart: leaf.address,
            intervalEnd: leaf.address,
            root: root,
            inclusionProof: inclusionProof.addressInclusionProof
        )
    }
}
