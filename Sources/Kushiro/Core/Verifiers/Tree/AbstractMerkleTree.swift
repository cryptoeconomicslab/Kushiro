//
//  AbstractMerkleTree.swift
//  Kushiro
//
//  Created by Koray Koska on 02.01.20.
//

import Foundation
import CryptoSwift

public protocol AbstractMerkleTree: MerkleTreeInterface {

    var levels: [[T]] { get set }

    var leaves: [T] { get }

    func calculateRoot(leaves: [T], level: Int)

    func getRoot() -> Data

    func findIndex(leaf: Data) -> Int?

    func getLeaf(index: Int) -> T

    func getInclusionProof(index: Int) -> InclusionProof<T>

    func getSiblingIndex(index: Int) -> Int

    func getParentIndex(index: Int) -> Int
}

extension AbstractMerkleTree {

    public mutating func calculateRoot(leaves: [T], level: Int) {
//        this.levels[level] = leaves
//        if (leaves.length <= 1) {
//          return
//        }
//        const parents: T[] = []
//        ArrayUtils.chunk(leaves, 2).forEach(c => {
//          if (c.length == 1) {
//            parents.push(
//              this.verifier.computeParent(c[0], this.verifier.createEmptyNode())
//            )
//          } else {
//            parents.push(this.verifier.computeParent(c[0], c[1]))
//          }
//        })
//        this.calculateRoot(parents, level + 1)
        levels[level] = leaves
        if leaves.count <= 1 {
            return
        }

        var parents = [T]()
        for i in stride(from: 0, to: leaves.count, by: 2) {
            if i + 1 < leaves.count - 1 {
//                parents.append(verifier.computeParent(a: leaves[i], b: leaves[i + 1]))
            }
        }
    }
}

public protocol ComparableMerkleTreeNode: MerkleTreeNode where T: Comparable {
}

public enum AbstractMerkleVerifierError: Swift.Error {

    case invalidRange(message: String)
    case invalidIntersection(message: String)
}

public protocol AbstractMerkleVerifier: Comparable {

    associatedtype T: ComparableMerkleTreeNode

    var hashAlgorithm: SHA3.Variant { get }

    func verifyInclusion(
      leaf: T,
      intervalStart: T.T,
      intervalEnd: T.T,
      root: Data,
      inclusionProof: InclusionProof<T>
    ) throws -> Bool

    func computeRootFromInclusionProof(
      leaf: T,
      merklePath: String,
      proofElement: [T]
    ) throws -> (root: Data, implicitEnd: T.T)

    func calculateMerklePath(inclusionProof: InclusionProof<T>) -> String

    func computeParent(a: T, b: T) -> T

    func createEmptyNode() -> T
}

extension AbstractMerkleVerifier {

    /**
     * verify inclusion of the leaf in certain range
     * @param leaf The leaf which is included in tree
     * @param intervalStart The start of range where the leaf is included in
     * @param intervalEnd The end of range where the leaf is included in
     * @param root Root hash of tree
     * @param inclusionProof Proof data to verify inclusion of the leaf
     */

    /// Verify inclusion of the leaf in certain range
    ///
    /// - parameter leaf: The leaf which is included in tree
    /// - parameter intervalStart: The start of range where the leaf is included in
    /// - parameter intervalEnd: The end of range where the leaf is included in
    /// - parameter root: Root hash of tree
    /// - parameter inclusionProof: Proof data to verify inclusion of the leaf
    public func verifyInclusion(
      leaf: T,
      intervalStart: T.T,
      intervalEnd: T.T,
      root: Data,
      inclusionProof: InclusionProof<T>
    ) throws -> Bool {
        let merklePath = calculateMerklePath(inclusionProof: inclusionProof)
        let computeIntervalRootAndEnd = try computeRootFromInclusionProof(
            leaf: leaf,
            merklePath: merklePath,
            proofElement: inclusionProof.siblings
        )

        if computeIntervalRootAndEnd.implicitEnd < intervalEnd || intervalStart < leaf.getInterval() {
            throw AbstractMerkleVerifierError.invalidRange(message: "required range must not exceed the implicit range")
        }

        return computeIntervalRootAndEnd.root == root
    }

    public func computeRootFromInclusionProof(
      leaf: T,
      merklePath: String,
      proofElement: [T]
    ) throws -> (root: Data, implicitEnd: T.T) {
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
                    throw AbstractMerkleVerifierError.invalidIntersection(message: "invalid InclusionProof, intersection detected")
                }
            }
            // check left.index < right.index
            computed = computeParent(a: left, b: right)
        }

        let implicitEnd = firstRightSibling != nil ? firstRightSibling!.getInterval() : createEmptyNode().getInterval()
        return (root: computed.data, implicitEnd: implicitEnd)
    }

    func calculateMerklePath(inclusionProof: InclusionProof<T>) -> String {
        return String(
            String(inclusionProof.leafPosition, radix: 2)
                .padding(toLength: inclusionProof.siblings.count, withPad: "0", startingAt: 0)
                .reversed()
        )
    }
}
