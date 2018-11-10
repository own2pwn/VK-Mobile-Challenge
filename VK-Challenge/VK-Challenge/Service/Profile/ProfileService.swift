//
//  VKAPIProfileService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

typealias VKProfileBlock = (VKProfileModel) -> Void

final class ProfileService {
    // MARK: - Members

    private let api: VKAPIClient

    // MARK: - Interface

    func getMyProfile(completion: @escaping VKProfileBlock) {
        let fields = makeQueryItem(field: .fields, params: [.photo100])

        api.getArray(method: .usersGet, params: [fields]) { (response: [VKProfileModel]) in
            if let me = response.first { completion(me) }
        }
    }

    // MARK: - Helpers

    private func makeQueryItem(field: VKAPIFeedField, params: [VKAPIFieldValue]) -> QueryItem {
        return QueryItem(field: field, values: params)
    }

    // MARK: - Init

    init(api: VKAPIClient) {
        self.api = api
    }
}
