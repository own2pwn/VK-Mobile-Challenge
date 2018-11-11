//
//  VKFeedItem.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKFeedItem: Decodable {
    let sourceID: Int
    let date: Date
    let postID: Int
    let text: String
    let attachments: [VKAttachment]?
    let comments: VKFeedItemComment
    let likes: VKFeedItemLike
    let reposts: VKFeedItemRepost
    let views: VKFeedItemView?
}

extension VKFeedItem: VKModelWithAttachment {
    var attachmentsOrEmpty: [VKAttachment] {
        return attachments ?? []
    }
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
        case date, text
        case comments, likes
        case reposts, views
        case attachments

        case sourceID = "source_id"
        case postID = "post_id"
    }
}
