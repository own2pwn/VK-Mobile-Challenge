//
// RequestSenderImp.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public final class RequestSenderImp: RequestSender {
    // MARK: - Members

    public let session: URLSession

    public let queue: DispatchQueue

    // MARK: - Interface

    @discardableResult
    public func send(_ request: URLRequest, completion: @escaping DataBlock) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, _, _ in
            if let value = data { completion(value) }
        }
        task.resume()

        return task
    }

    // MARK: - Init

    public convenience init() {
        let custom = URLSessionConfiguration.default
        custom.timeoutIntervalForRequest = 10
        custom.timeoutIntervalForResource = 20

        let session = URLSession(configuration: custom)
        self.init(session: session)
    }

    public convenience init(session: URLSession) {
        let queue = DispatchQueue(label: "own2pwn.net.core", attributes: .concurrent)

        self.init(session: session, queue: queue)
    }

    public init(session: URLSession, queue: DispatchQueue) {
        self.session = session
        self.queue = queue
    }
}
