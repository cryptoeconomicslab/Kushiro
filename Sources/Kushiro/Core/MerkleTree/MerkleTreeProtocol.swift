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

public typealias MerkleTreeGenerator<I, T, S: MerkleTreeProtocol> = (_ leaves: [T]) throws -> S where T.T == I, S.I == I, S.T == T

public protocol MerkleTreeProtocol {

    associatedtype I

    associatedtype T: MerkleTreeNode where T.T == I

    func getRoot() -> Data

    func findIndex(leaf: Data) -> Int?

    func getLeaf(index: Int) -> T
}

public protocol MerkleTreeVerifier {

    associatedtype B

    associatedtype I

    associatedtype T: MerkleTreeNode where T.T == I

    func verifyInclusion(leaf: T, interval: B, root: Data, inclusionProof: I) -> Bool
}

public struct InclusionProof<I, T: MerkleTreeNode> where T.T == I {

    let leafIndex: I
    let leafPosition: Int
    let siblings: [T]

    public init(leafIndex: I, leafPosition: Int, siblings: [T]) {
        self.leafIndex = leafIndex
        self.leafPosition = leafPosition
        self.siblings = siblings
    }
}

extension InclusionProof: Codable where I: Codable, T: Codable {
}

extension InclusionProof: Equatable where I: Equatable, T: Equatable {
}
