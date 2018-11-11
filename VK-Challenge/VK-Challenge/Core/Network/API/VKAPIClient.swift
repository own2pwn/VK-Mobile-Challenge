//
//  VKAPIClient.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class VKAPIClient {
    // MARK: - Members

    private let version: String

    private let token: String

    private let provider: ResponseProvider

    // MARK: - Interface

    func get<M: Decodable>(method: VKAPIMethod, params: [QueryItem], completion: @escaping ModelBlock<M>) {
        let query = fillQuery(params)

        provider.get(url: method.value, query: query) { (response: VKAPIResponse<M>) in
            completion(response.response)
        }
    }

    func getArray<M: Decodable>(method: VKAPIMethod, params: [QueryItem], completion: @escaping ModelBlock<[M]>) {
        let query = fillQuery(params)

        provider.get(url: method.value, query: query) { (response: VKAPIArrayResponse<M>) in
            completion(response.response)
        }
    }

    private func fillQuery(_ params: [QueryItem]) -> [QueryItem] {
        var filled = params
        let versionParam = QueryItem(field: VKAPIField.version, value: version)
        let tokenParam = QueryItem(field: VKAPIField.token, value: token)
        filled.append(versionParam)
        filled.append(tokenParam)

        return filled
    }

    // MARK: - Init

    init(token: String, provider: ResponseProvider) {
        self.token = token
        self.provider = provider

        version = "5.87"
    }
}
