//
//  EthereumAddress+CustomHex.swift
//  Kushiro
//
//  Created by Koray Koska on 18.01.20.
//

import Foundation
import Web3

extension EthereumAddress {

    func customHex() -> String {
        return hex(eip55: false).lowercased()
    }
}
