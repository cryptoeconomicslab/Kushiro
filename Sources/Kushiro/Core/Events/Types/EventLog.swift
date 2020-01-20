//
//  EventLog.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation

public protocol EventLog {

    var name: String { get }
    var values: [Data] { get }
}
