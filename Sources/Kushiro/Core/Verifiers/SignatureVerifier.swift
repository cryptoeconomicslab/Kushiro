//
//  SignatureVerifier.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation
import Web3
import PromiseKit

public protocol SignatureVerifier {

    func verify(message: Data, signature: Data, publicKey: EthereumPublicKey) -> Promise<Bool>
}
