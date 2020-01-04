//
//  CommitmentContractWatcher.swift
//  Kushiro
//
//  Created by Koray Koska on 04.01.20.
//

import Foundation

public class CommitmentContractWatcher {

    public typealias Listener = (_ event: BlockSubmitted) -> Void

    private let inner: EventWatcher

    private var listeners: [String: (handler: Listener, listener: (_ event: EventLog) throws -> Void)]

    public init(eventWatcher: EventWatcher) {
        self.inner = eventWatcher
        self.listeners = [:]
    }

    public func subscribeBlockSubmittedEvent(uid: String, handler: @escaping Listener) {
        let listener: (_ event: EventLog) throws -> Void = { event in
            let blockSubmitted = try BlockSubmitted(event: event)
            handler(blockSubmitted)
        }

        listeners[uid] = (handler: handler, listener: listener)
    }

    public func unsubscribeBlockSubmittedEvent(uid: String) {
        if let listener = listeners[uid] {
            inner.unsubscribe(event: "block_submitted", handler: listener.listener)
        }
    }
}
