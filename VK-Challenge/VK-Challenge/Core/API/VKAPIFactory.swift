//
//  VKAPIFactory.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

typealias VKAPIProfileService = VKAPIService<VKAPIMethodUsers, VKAPIAnyFilter, VKAPIUsersField>

typealias VKAPIFeedService = VKAPIService<VKAPIMethodFeed, VKAPIFeedFilter, VKAPIFeedField>

final class VKAPIFactory {
    // MARK: - Members

    private let token: String

    // MARK: - Interface

    func makeProfileService() -> VKAPIProfileService {
        return VKAPIProfileService(token: token)
    }

    func makeFeedService() -> VKAPIFeedService {
        return VKAPIFeedService(token: token)
    }

    // MARK: - Init

    init(token: String) {
        self.token = token
    }
}
