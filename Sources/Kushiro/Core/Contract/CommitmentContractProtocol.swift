//
//  CommitmentContractProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import BigInt
import Web3
import PromiseKit

public protocol CommitmentContractProtocol {

    func submit(blockNumber: EthereumQuantity, root: Data) -> Promise<Void>

    func getCurrentBlock() -> Promise<EthereumQuantity>

    func getRoot(blockNumber: EthereumQuantity) -> Promise<Data>

    // MARK: - Subscribe functions

    func subscribeBlockSubmitted(handler: (_ blockNumber: EthereumQuantity, _ root: Data) -> Void)
}
