//
//  BlockSubmitted.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation

public struct BlockSubmitted {

    public let blockNumber: Int

    public let root: Data

    public init(blockNumber: Int, root: Data) {
        self.blockNumber = blockNumber
        self.root = root
    }

    public init(event: EventLog) throws {
        let blockNumber = try Int(data: event.values[0])
        let root = event.values[1]

        self.init(blockNumber: blockNumber, root: root)
    }
}
