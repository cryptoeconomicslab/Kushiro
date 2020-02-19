//
//  AbstractMerkleTree.swift
//  Kushiro
//
//  Created by Koray Koska on 02.01.20.
//

import Foundation
import CryptoSwift

public protocol GenericMerkleTree: MerkleTreeProtocol where T.T == B {

    associatedtype B

    associatedtype T

    associatedtype Verifier: GenericMerkleVerifier where Verifier.B == B, Verifier.T == T

    var levels: [[T]] { get set }

    var leaves: [T] { get }

    var verifier: Verifier { get }

    init(leaves: [T], verifier: Verifier) throws

    mutating func calculateRoot(leaves: [T], level: Int) throws

    func getRoot() -> Data

    func findIndex(leaf: Data) -> Int?

    func getLeaf(index: Int) -> T

    func getInclusionProof(index: Int) -> InclusionProof<B, T>

    func getSiblingIndex(index: Int) -> Int

    func getParentIndex(index: Int) -> Int
}

extension GenericMerkleTree {

    public mutating func calculateRoot(leaves: [T], level: Int) throws {
        if levels.count > level {
            levels[level] = leaves
        } else {
            levels.append(leaves)
        }
        if leaves.count <= 1 {
            return
        }

        var parents = [T]()
        for i in stride(from: 0, to: leaves.count, by: 2) {
            if i + 1 < leaves.count {
                parents.append(try verifier.computeParent(a: leaves[i], b: leaves[i + 1]))
            } else {
                parents.append(try verifier.computeParent(a: leaves[i], b: verifier.createEmptyNode()))
            }
        }

        try calculateRoot(leaves: parents, level: level + 1)
    }

    public func getRoot() -> Data {
        return levels[levels.count - 1][0].data
    }

    public func findIndex(leaf: Data) -> Int? {
        let index = leaves.firstIndex { l in
            return l.data == leaf
        }

        return index
    }

    public func getLeaf(index: Int) -> T {
        return leaves[index]
    }

    public func getInclusionProof(index: Int) -> InclusionProof<B, T> {
        var inclusionProofElement = [T]()
        var parentIndex: Int
        var siblingIndex = getSiblingIndex(index: index)

        for i in 0..<(levels.count - 1) {
            let level = levels[i]
            let node = level[safe: siblingIndex] ?? verifier.createEmptyNode()
            inclusionProofElement.append(node)
            // Calculate parent index and its sibling index
            parentIndex = getParentIndex(index: siblingIndex)
            siblingIndex = getSiblingIndex(index: parentIndex)
        }

        return InclusionProof(leafIndex: levels[0][index].getInterval(), leafPosition: index, siblings: inclusionProofElement)
    }

    ///
    /// Calculates sibling index
    ///
    /// p
    ///
    /// / \
    ///
    /// i  sibling
    ///
    /// - parameter index: The index to search the sibling from
    /// - returns: Sibling index of `index`.
    public func getSiblingIndex(index: Int) -> Int {
        return index + (index % 2 == 0 ? 1 : -1)
    }

    ///
    /// Calculates parent index
    ///
    /// parent
    ///
    /// / \
    ///
    /// i  s
    ///
    /// - parameter index: The index to search the parent from
    /// - returns: Parent index of `index`.
    public func getParentIndex(index: Int) -> Int {
        return index == 0 ? 0 : Int(floor(Double(index / 2)))
    }
}

public enum GenericMerkleVerifierError: Swift.Error {

    case invalidRange(message: String)
    case invalidIntersection(message: String)
}

public protocol GenericMerkleVerifier {

    associatedtype B where B: Comparable

    associatedtype T: MerkleTreeNode where T.T == B

    var hashAlgorithm: SHA3.Variant { get }

    func verifyInclusion(
      leaf: T,
      intervalStart: B,
      intervalEnd: B,
      root: Data,
      inclusionProof: InclusionProof<B, T>
    ) throws -> Bool

    func computeRootFromInclusionProof(
      leaf: T,
      merklePath: String,
      proofElement: [T]
    ) throws -> (root: Data, implicitEnd: B)

    func calculateMerklePath(inclusionProof: InclusionProof<B, T>) -> String

    func computeParent(a: T, b: T) throws -> T

    func createEmptyNode() -> T
}

extension GenericMerkleVerifier {

    public var hashAlgorithm: SHA3.Variant {
        return .keccak256
    }

    /// Verify inclusion of the leaf in certain range
    ///
    /// - parameter leaf: The leaf which is included in tree
    /// - parameter intervalStart: The start of range where the leaf is included in
    /// - parameter intervalEnd: The end of range where the leaf is included in
    /// - parameter root: Root hash of tree
    /// - parameter inclusionProof: Proof data to verify inclusion of the leaf
    public func verifyInclusion(
      leaf: T,
      intervalStart: B,
      intervalEnd: B,
      root: Data,
      inclusionProof: InclusionProof<B, T>
    ) throws -> Bool {
        let merklePath = calculateMerklePath(inclusionProof: inclusionProof)
        let computeIntervalRootAndEnd = try computeRootFromInclusionProof(
            leaf: leaf,
            merklePath: merklePath,
            proofElement: inclusionProof.siblings
        )

        if computeIntervalRootAndEnd.implicitEnd < intervalEnd || intervalStart < leaf.getInterval() {
            throw GenericMerkleVerifierError.invalidRange(message: "required range must not exceed the implicit range")
        }

        return computeIntervalRootAndEnd.root == root
    }

    public func computeRootFromInclusionProof(
      leaf: T,
      merklePath: String,
      proofElement: [T]
    ) throws -> (root: Data, implicitEnd: B) {
        let firstIndex = merklePath.firstIndex(of: "0")
        let firstRightSiblingIndex: Int? = firstIndex != nil ? merklePath.distance(from: merklePath.startIndex, to: firstIndex!) : nil
        let firstRightSibling = firstRightSiblingIndex != nil ? proofElement[firstRightSiblingIndex!] : nil

        var computed = leaf
        var left: T
        var right: T
        for i in 0..<proofElement.count {
            let sibling = proofElement[i]

            if merklePath[safe: i] == "1" {
                left = sibling
                right = computed
            } else {
                left = computed
                right = sibling

                if firstRightSibling != nil && right.getInterval() < firstRightSibling!.getInterval() {
                    throw GenericMerkleVerifierError.invalidIntersection(message: "invalid InclusionProof, intersection detected")
                }
            }
            // check left.index < right.index
            computed = try computeParent(a: left, b: right)
        }

        let implicitEnd = firstRightSibling != nil ? firstRightSibling!.getInterval() : createEmptyNode().getInterval()
        return (root: computed.data, implicitEnd: implicitEnd)
    }

    public func calculateMerklePath(inclusionProof: InclusionProof<B, T>) -> String {
        return String(
            String(inclusionProof.leafPosition, radix: 2)
                .paddingLeft(toLength: inclusionProof.siblings.count, withPad: "0")
                .reversed()
        )
    }
}
