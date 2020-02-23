//
//  AdjudicationContractProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import PromiseKit
import BigInt

public protocol AdjudicationContractProtocol {

    ///
    /// Gets instantiated challenge game by gameId.
    ///
    /// - parameter gameId: The id of the game.
    ///
    func getGame(gameId: Data) -> Promise<ChallengeGame>

    ///
    /// Returns whether a game is decided or not.
    ///
    /// - parameter gameId: The id of the game.
    ///
    func isDecided(gameId: Data) -> Promise<Bool>

    ///
    /// Claims a property to create new game.
    ///
    /// - parameter gameId: The property to claim.
    ///
    func claimProperty(property: Property) -> Promise<Void>

    ///
    /// Decide a claim to true.
    ///
    /// - parameter gameId: The id of the game.
    ///
    func decideClaimToTrue(gameId: Data) -> Promise<Void>

    ///
    /// Decide a claim to false.
    ///
    /// - parameter gameId: The id of the game.
    ///
    func decideClaimToFalse(gameId: Data, challengingGameId: Data) -> Promise<Void>

    ///
    /// Remove a challange of a game.
    ///
    /// - parameter gameId: The id of the game.
    /// - parameter challengingGameId: The id of the challange to remove.
    ///
    func removeChallenge(gameId: Data, challengingGameId: Data) -> Promise<Void>

    ///
    /// Set predicate decision to decide a game.
    ///
    /// - parameter gameId: The id of the game.
    /// - parameter decision: The decision.
    ///
    func setPredicateDecision(gameId: Data, decision: Bool) -> Promise<Void>

    ///
    /// Challenge a game specified by `gameId` with a challengingGame specified by `challengingGameId`.
    ///
    /// - parameter gameId: The id of the game.
    /// - parameter challengeInputs: The inputs for the challange game.
    /// - parameter challengingGameId: The id of the challanging game.
    ///
    func challenge(gameId: Data, challengeInputs: [Data], challengingGameId: Data) -> Promise<Void>

    // MARK: - Subscribe functions

    func subscribeAtomicPropositionDecided(handler: (_ gameId: Data, _ decision: Bool) -> Void)

    func subscribeNewPropertyClaimed(handler: (_ gameId: Data, _ property: Property, _ createdBlock: BigInt) -> Void)

    func subscribeClaimChallenged(handler: (_ gameId: Data, _ challengeGameId: Data) -> Void)

    func subscribeClaimDecided(handler: (_ gameId: Data, _ decision: Bool) -> Void)

    func subscribeChallengeRemoved(handler: (_ gameId: Data, _ challengeGameId: Data) -> Void)
}
