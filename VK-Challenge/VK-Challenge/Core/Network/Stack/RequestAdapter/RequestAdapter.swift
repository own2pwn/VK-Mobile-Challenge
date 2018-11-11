//
// RequestAdapter.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public protocol RequestAdapter: class {
    static func adapt(_ endpoint: String) -> URL?
    static func adapt(_ parts: [String]) -> URL?

    func adapt(_ part: String) -> URL?
    func adapt(_ parts: [String]) -> URL?

    func adapt(_ part: String, query: [QueryItem]) -> URL?
    func adapt(_ parts: [String], query: [QueryItem]) -> URL?
}

public protocol RequestField {
    var value: String { get }
}

public protocol RequestFieldValue {
    var value: String { get }
}

public protocol URLAdaptable {
    var value: String { get }
}
