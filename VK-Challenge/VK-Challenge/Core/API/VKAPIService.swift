//
//  VKAPIService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class VKAPIService<M: VKAPIMethod, T: VKAPIFilter, F: VKAPIField> {
    // MARK: - Members

    private let token: String

    private let endpoint: URL

    private lazy var session: URLSession = {
        var config = URLSession.shared.configuration
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        let custom = URLSession(configuration: config)

        return custom
    }()

    // MARK: - Interface

    func getArray<R: Decodable>(_ method: M, filters: [T] = [], fields: [F], completion: @escaping (([R]) -> Void)) {
        var concrete = endpoint
        concrete.appendPathComponent(method.value)

        guard var components = URLComponents(url: concrete, resolvingAgainstBaseURL: false) else { return }
        components.queryItems = makeQueryItems(with: filters, params: fields)

        guard let url = components.url else {
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                assertionFailure()
                return
            }

            self.handleArrayResponse(data, httpResponse: response, error: error, with: completion)
        }

        task.resume()
    }

    func getSingle<R: Decodable>(_ method: M, filters: [T] = [], fields: [F], completion: @escaping ((R) -> Void)) {
        var concrete = endpoint
        concrete.appendPathComponent(method.value)

        guard var components = URLComponents(url: concrete, resolvingAgainstBaseURL: false) else { return }
        components.queryItems = makeQueryItems(with: filters, params: fields)

        guard let url = components.url else {
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                assertionFailure()
                return
            }

            self.handleSingleResponse(data, httpResponse: response, error: error, with: completion)
        }

        task.resume()
    }

    // MARK: - Helpers

    private func handleSingleResponse<R: Decodable>(_ data: Data, httpResponse: URLResponse?, error: Error?, with completion: @escaping ((R) -> Void)) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        if let model = try? decoder.decode(VKAPIResponse<R>.self, from: data) {
            completion(model.response)
        }
    }

    private func handleArrayResponse<R: Decodable>(_ data: Data, httpResponse: URLResponse?, error: Error?, with completion: @escaping (([R]) -> Void)) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        if let model = try? decoder.decode(VKAPIArrayResponse<R>.self, from: data) {
            completion(model.response)
        }
    }

    private func makeQueryItems(with filters: [T], params: [F]) -> [URLQueryItem] {
        let fields = params.map { $0.value }.joined(separator: ",")
        let filterStr = filters.map { $0.value }.joined(separator: ",")

        var dict = ["fields": fields,
                    "access_token": token,
                    "v": CONST.VK.apiVersion]

        if !filters.isEmpty {
            dict["filters"] = filterStr
        }

        var result = [URLQueryItem]()
        for (k, v) in dict {
            result.append(URLQueryItem(name: k, value: v))
        }

        return result
    }

    // MARK: - Init

    init(token: String) {
        self.token = token
        endpoint = URL(string: CONST.VK.apiEndpoint)!
    }
}
