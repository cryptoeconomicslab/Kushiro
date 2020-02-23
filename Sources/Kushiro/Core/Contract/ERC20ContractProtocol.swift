//
//  ERC20ContractProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import PromiseKit
import Web3

public protocol ERC20ContractProtocol {

    var address: EthereumAddress { get }

    ///
    /// Approve other contract to handle ERC20 balance
    ///
    func approve(spender: EthereumAddress, amount: EthereumQuantity) -> Promise<Void>
}
