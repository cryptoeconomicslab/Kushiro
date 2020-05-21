//
//  OwnershipPayoutContractProtocol.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import Web3
import PromiseKit

public protocol OwnershipPayoutContractProtocol {

    func finalizeExit(
        depositContractAddress: EthereumAddress,
        exitProperty: Property,
        depositedRangeId: BigInt,
        owner: EthereumAddress
    ) -> Promise<Void>
}
