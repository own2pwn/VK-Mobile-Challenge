//
//  VKAPIService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class VKAPIService<M: VKAPIMethod, F: VKAPIField> {
    // MARK: - Members

    private let token: String

    private let endpoint: URL

    // MARK: - Interface

    func buildRequest(for method: M, with fields: [F]) -> URLRequest? {
        var concrete = endpoint
        concrete.appendPathComponent(method.value)

        guard var components = URLComponents(url: concrete, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = makeQueryItems(with: fields)

        guard let result = components.url else {
            return nil
        }

        return URLRequest(url: result)
    }

    // MARK: - Helpers

    private func makeQueryItems(with params: [F]) -> [URLQueryItem] {
        let fields = params.map { $0.value }.joined(separator: ",")

        let dict = ["fields": fields,
                    "access_token": token,
                    "v": CONST.VK.apiVersion]

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
