//
//  Types.swift
//  Kushiro
//
//  Created by Koray Koska on 23.02.20.
//

import Foundation
import Web3
import BigInt

public struct Property: Codable {

    public let deciderAddress: EthereumAddress

    public let inputs: Data

    public init(deciderAddress: EthereumAddress, inputs: Data) {
        self.deciderAddress = deciderAddress
        self.inputs = inputs
    }
}

public struct ChallengeGame {

    public let property: Property

    public let challanges: Data

    public let decision: Bool

    public let createdBlock: BigInt
}
