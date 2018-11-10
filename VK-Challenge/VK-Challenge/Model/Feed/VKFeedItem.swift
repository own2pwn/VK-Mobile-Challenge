//
//  VKFeedItem.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKFeedItem: Decodable {
    let type: String
    let sourceID: Int
    let date: Date
    let postID: Int
    let postType: String
    let text: String
    let comments: VKFeedItemComment
    let likes: VKFeedItemLike
    let reposts: VKFeedItemRepost
    let views: VKFeedItemView?
}

struct VKFeedItemComment: Decodable {
    let count: Int
}

struct VKFeedItemLike: Decodable {
    let count: Int
    private let user_likes: Int

    var userLikes: Bool {
        return user_likes == 1
    }
}

struct VKFeedItemRepost: Decodable {
    let count: Int
    private let user_reposted: Int

    var userReposted: Bool {
        return user_reposted == 1
    }
}

struct VKFeedItemView: Decodable {
    let count: Int
}

extension VKFeedItem {
    enum CodingKeys: String, CodingKey {
        case type, date, text
        case comments, likes
        case reposts, views

        case sourceID = "source_id"
        case postID = "post_id"
        case postType = "post_type"
    }
}
