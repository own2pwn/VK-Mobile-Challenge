//
// RequestSender.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public typealias DataBlock = (Data) -> Void

public protocol RequestSender: class {
    @discardableResult
    func send(_ request: URLRequest, completion: @escaping DataBlock) -> URLSessionDataTask
}
