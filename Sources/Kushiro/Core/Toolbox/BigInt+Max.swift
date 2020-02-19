//
//  BigInt+Max.swift
//  BigInt
//
//  Created by Koray Koska on 18.02.20.
//

import Foundation
import BigInt

extension BigInt {

    static var max256Bit: BigInt {
        return BigInt(2).power(256) - BigInt(1)
    }
}
