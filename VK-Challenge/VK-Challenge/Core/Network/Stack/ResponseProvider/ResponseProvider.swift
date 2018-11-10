//
// ResponseProvider.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public typealias ModelBlock<M: Decodable> = ((M) -> Void)

public protocol ResponseProvider: class {
    func get<Model: Decodable>(url: String, query: [QueryItem], completion: @escaping ModelBlock<Model>)
    func get<Model: Decodable>(url: [String], query: [QueryItem], completion: @escaping ModelBlock<Model>)
}
