//
//  Ed25519Verifier.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation
import Web3
import PromiseKit

public struct Ed25519Verifier: SignatureVerifier {

    public func verify(message: Data, signature: Data, publicKey: EthereumPublicKey) -> Promise<Bool> {
        // TODO: Implement Web3 message verifier
        return Promise { seal in
            seal.fulfill(true)
        }
    }
}
