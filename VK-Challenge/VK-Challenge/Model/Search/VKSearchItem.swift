//
//  VKSearchItem.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKSearchItem: Decodable {
    let date: Date
    let postID: Int?
    let postType: String
    let text: String
    let attachments: [VKAttachment]?
    let comments: VKFeedItemComment
    let likes: VKFeedItemLike
    let reposts: VKFeedItemRepost
    let views: VKFeedItemView?
    let ownerID: Int

    var sourceID: Int {
        return ownerID
    }
}

extension VKSearchItem: VKModelWithAttachment {
    var attachmentsOrEmpty: [VKAttachment] {
        return attachments ?? []
    }
}

extension VKSearchItem {
    enum CodingKeys: String, CodingKey {
        case date, text
        case comments, likes
        case reposts, views
        case attachments

        case ownerID = "owner_id"
        // case sourceID = "source_id"
        case postID = "post_id"
        case postType = "post_type"
    }
}
