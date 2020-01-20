//
//  EventWatcher.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation

public protocol EventWatcher {

    typealias EventHandler = (_ event: EventLog) throws -> Void
    typealias CompletedHandler = () -> Void
    typealias ErrorHandler = (_ err: Error) -> Void

    func subscribe(event: String, handler: EventHandler)

    func unsubscribe(event: String, handler: EventHandler)

    func start(handler: CompletedHandler, errorHandler: ErrorHandler?)
}
