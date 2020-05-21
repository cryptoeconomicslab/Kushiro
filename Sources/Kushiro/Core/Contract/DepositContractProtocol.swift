//
//  DepositContractProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import Web3
import PromiseKit

public protocol DepositContractProtocol {

    var address: EthereumAddress { get }

    ///
    /// Deposits amount of ETH with initial state.
    ///
    /// - parameter amount: Amount of ETH in GWEI.
    /// - parameter initialState: Initial state of the range.
    ///
    func deposit(amount: EthereumQuantity, initialState: Property) -> Promise<Void>

    ///
    /// Finalizes checkpoint claim.
    ///
    /// - parameter checkpoint: Checkpoint property which has been decided true by Adjudicator Contract.
    ///
    func finalizeCheckpoint(checkpoint: Property) -> Promise<Void>

    ///
    /// Finalizes exit claim and withdraw fund.
    ///
    /// - parameter exit: The exit property which has been decided true by Adjudicator Contract.
    /// - parameter depositedRangeId: The id of range. We can know depositedRangeId from deposited event and finalizeExited event.
    ///
    func finalizeExit(exit: Property, depositedRangeId: EthereumQuantity) -> Promise<Void>

    // MARK: - Subscribe functions

    ///
    /// subscribe to checkpoint finalized event
    ///
    func subscribeCheckpointFinalized(handler: (_ checkpointId: Data, _ checkpoint: (range: Range<Int>, property: Property)) -> Void)

    ///
    /// subscribe to exit finalized event
    ///
    func subscribeExitFinalized(handler: (_ exitId: Data) -> Void)
}
