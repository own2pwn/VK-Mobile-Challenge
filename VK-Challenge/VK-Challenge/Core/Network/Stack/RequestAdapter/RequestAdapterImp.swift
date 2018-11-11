//
// RequestAdapterImp.swift
// NetworkStack
//
// Created by Evgeniy on 10/11/2018.
// Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public final class RequestAdapterImp: RequestAdapter {
    // MARK: - Members

    private let endpoint: String

    // MARK: - Interface

    public static func adapt(_ endpoint: String) -> URL? {
        return URL(string: endpoint)
    }

    public static func adapt(_ parts: [String]) -> URL? {
        let endpoint = parts.joined()

        return URL(string: endpoint)
    }

    // ====

    public func adapt(_ part: String) -> URL? {
        guard var adaptedURL = URL(string: endpoint) else {
            return nil
        }
        adaptedURL.appendPathComponent(part)

        return adaptedURL
    }

    public func adapt(_ parts: [String]) -> URL? {
        guard var adaptedURL = URL(string: endpoint) else {
            return nil
        }
        for part in parts {
            adaptedURL.appendPathComponent(part)
        }
        return adaptedURL
    }

    // ====

    public func adapt(_ part: String, query: [QueryItem]) -> URL? {
        guard
            let adapted = adapt(part),
            var components = URLComponents(url: adapted, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = makeQueryItems(from: query)

        return components.url
    }

    public func adapt(_ parts: [String], query: [QueryItem]) -> URL? {
        guard
            let adapted = adapt(parts),
            var components = URLComponents(url: adapted, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = makeQueryItems(from: query)

        return components.url
    }

    private func makeQueryItems(from query: [QueryItem]) -> [URLQueryItem] {
        let result = query.map { (item: QueryItem) -> URLQueryItem in
            let fieldValue = item.values.map { $0.value }.joined(separator: ",")

            return URLQueryItem(name: item.field.value, value: fieldValue)
        }

        return result
    }

    // MARK: - Init

    public init(endpoint: String) {
        self.endpoint = endpoint
    }
}
