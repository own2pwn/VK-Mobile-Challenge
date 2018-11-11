//
// ResponseProviderImp.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//
import Foundation

public final class ResponseProviderImp: ResponseProvider {
    // MARK: - Members

    private let adapter: RequestAdapter

    private let sender: RequestSender

    // MARK: - Interface

    public func get<Model: Decodable>(url: String, query: [QueryItem], completion: @escaping ModelBlock<Model>) {
        guard let url = adapter.adapt(url, query: query) else { return }

        let request = URLRequest(url: url)
        sender.send(request) { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            #if DEBUG
                do {
                    let model = try decoder.decode(Model.self, from: data)
                    completion(model)
                } catch {
                    print(error)
                }
            #else
                if let model = try? decoder.decode(Model.self, from: data) {
                    completion(model)
                }
            #endif
        }
    }

    public func get<Model: Decodable>(url: [String], query: [QueryItem], completion: @escaping ModelBlock<Model>) {
        guard let url = adapter.adapt(url, query: query) else { return }

        let request = URLRequest(url: url)
        sender.send(request) { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970

            #if DEBUG
                do {
                    let model = try decoder.decode(Model.self, from: data)
                    completion(model)
                } catch {
                    print(error)
                }
            #else
                if let model = try? decoder.decode(Model.self, from: data) {
                    completion(model)
                }
            #endif
        }
    }

    // MARK: - Init

    public init(adapter: RequestAdapter, sender: RequestSender) {
        self.adapter = adapter
        self.sender = sender
    }
}
