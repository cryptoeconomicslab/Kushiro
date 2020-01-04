//
//  Wallet.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation
import Web3
import PromiseKit

public protocol Wallet {

    func getAddress() -> EthereumAddress

    func getL1Balance(tokenAddress: EthereumAddress) -> Promise<EthereumQuantity>

    /// Signs the given message and returns the signature
    ///
    /// - parameter message: The message to sign (the hex string of the data will be signed)
    func signMessage(message: Data) -> Promise<Data>

    /// Verify message and signature from publicKey
    /// Some cryptographic algorithms don't need a publicKey to verify the signature.
    ///
    /// - parameter message: The original message.
    /// - parameter signature: The signature to verify.
    /// - parameter publicKey: Optional. Used to verify some cryptographic signatures.
    func verifySignature(message: Data, signature: Data, publicKey: EthereumPublicKey?) -> Promise<Bool>
}
