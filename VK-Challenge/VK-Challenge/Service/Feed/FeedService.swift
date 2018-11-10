//
//  FeedService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class FeedService {
    // MARK: - Members

    private let api: VKAPIFeedService

    // MARK: - Interface

    func getNews(completion: @escaping ((VKFeedResponseModel) -> Void)) {
        api.getSingle(.feedGet, filters: [.post], fields: [.photo100]) { (response: VKFeedResponseModel) in
            completion(response)
        }
    }

    // MARK: - Init

    init(api: VKAPIFeedService) {
        self.api = api
    }
}
