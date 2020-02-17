//
//  DoubleLayerTree.swift
//  Kushiro
//
//  Created by Koray Koska on 17.01.20.
//

import Foundation
import Web3

public struct DoubleLayerInclusionProof {

    let intervalInclusionProof: IntervalTreeInclusionProof

    let addressInclusionProof: AddressTreeInclusionProof

    public init(intervalInclusionProof: IntervalTreeInclusionProof, addressInclusionProof: AddressTreeInclusionProof) {
        self.intervalInclusionProof = intervalInclusionProof
        self.addressInclusionProof = addressInclusionProof
    }
}

public struct DoubleLayerInterval {

    let start: Int

    let address: EthereumAddress

    public init(start: Int, address: EthereumAddress) {
        self.start = start
        self.address = address
    }
}

public class DoubleLayerTreeLeaf: MerkleTreeNode {

    public typealias T = DoubleLayerInterval

    public let address: EthereumAddress

    public let start: Int

    public let data: Data

    public init(address: EthereumAddress, start: Int, data: Data) {
        self.address = address
        self.start = start
        self.data = data
    }

    public func encode() -> Data {
        var encoding = data
        // Force unwrap is ok because of .utf8 encoding
        // see: https://www.objc.io/blog/2018/02/13/string-to-data-and-back/
        encoding.append(contentsOf: address.hex(eip55: false).data(using: .utf8)!)

        return encoding
    }

    public func getInterval() -> DoubleLayerInterval {
        return DoubleLayerInterval(start: start, address: address)
    }
}

/// Can be used as a `MerkleTreeGenerator<DoubleLayerInterval, DoubleLayerTreeLeaf>`
public func generateDoubleLayerTree(leaves: [DoubleLayerTreeLeaf]) -> DoubleLayerTree {
    return DoubleLayerTree(leaves: leaves)
}

/**
 * DoubleLayerTree class
 *     This class construct double layer tree which has 2 layers.
 *     The 1st layer is address tree and 2nd layer is interval tree.
 *     Please see https://docs.plasma.group/projects/spec/en/latest/src/01-core/double-layer-tree.html
 *
 */
public class DoubleLayerTree: MerkleTreeProtocol {

    public typealias I = DoubleLayerInterval

    public typealias T = DoubleLayerTreeLeaf

    public let addressTree: AddressTree

    public private(set) var intervalTreeMap: [String: IntervalTree] = [:]

    private let leaves: [DoubleLayerTreeLeaf]

    public init(leaves: [DoubleLayerTreeLeaf]) {
        self.leaves = leaves

        var addressTreeLeaves = [AddressTreeNode]()

        let addressLeavesMap = leaves.reduce([:] as [String: [IntervalTreeNode]]) { result, leaf in
            var result = result

            let address = leaf.address.hex(eip55: false)

            var map = result[address] ?? []
            map.append(try! IntervalTreeNode(start: leaf.start, data: leaf.data))

            result[address] = map

            return result
        }

        for (key, value) in addressLeavesMap {
            let intervalTree = IntervalTree(leaves: value)
            self.intervalTreeMap[key] = intervalTree

            addressTreeLeaves.append(
                try! AddressTreeNode(address: EthereumAddress(hex: key, eip55: false), data: intervalTree.getRoot())
            )
        }

        self.addressTree = AddressTree(leaves: addressTreeLeaves)
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

    public func getLeaves(address: EthereumAddress, start: Int, end: Int) -> [Int] {
        let tree = intervalTreeMap[address.hex(eip55: false)]

        return tree?.getLeaves(start: start, end: end) ?? []
    }

    public func getInclusionProofByAddressAndIndex(address: EthereumAddress, index: Int) -> DoubleLayerInclusionProof? {
        if let addressTreeIndex = addressTree.getIndexByAddress(address: address), let intervalTree = intervalTreeMap[address.hex(eip55: false)] {
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
