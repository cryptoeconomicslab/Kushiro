//
//  MerkleTreeProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 28.12.19.
//

import Foundation

public protocol MerkleTreeNode {

    associatedtype T

    var data: Data { get }

    func getInterval() -> T

    func encode() -> Data
}

public protocol MerkleTreeGenerator {

    associatedtype T: MerkleTreeNode

    func generate<I: MerkleTreeInterface>(leaves: [T]) -> I
}

public protocol MerkleTreeInterface {

    associatedtype T: MerkleTreeNode

    func getRoot() -> Data

    func findIndex(leaf: Data) -> Int?

    func getLeaf(index: Int) -> T
}

public protocol MerkleTreeVerifier {

    associatedtype B

    associatedtype T: MerkleTreeNode

    func verifyInclusion(leaf: T, interval: B, root: Data, inclusionProof: T.T) -> Bool
}

public class InclusionProof<T: MerkleTreeNode> {

    let leafIndex: T.T
    let leafPosition: Int
    let siblings: [T]

    public init(leafIndex: T.T, leafPosition: Int, siblings: [T]) {
        self.leafIndex = leafIndex
        self.leafPosition = leafPosition
        self.siblings = siblings
    }
}
