//
//  VKAPIFactory.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class VKAPIFactory {
    // MARK: - Members

    private let token: String

    private lazy var api: VKAPIClient = {
        let adapter = RequestAdapterImp(endpoint: "https://api.vk.com/method")
        let sender = RequestSenderImp()
        let provider = ResponseProviderImp(adapter: adapter, sender: sender)
        let client = VKAPIClient(token: token, provider: provider)

        return client
    }()

    // MARK: - Interface

    func makeProfileService() -> ProfileService {
        return ProfileService(api: api)
    }

    func makeFeedService() -> FeedService {
        return FeedService(api: api)
    }

    // MARK: - Init

    init(token: String) {
        self.token = token
    }
}
