//
//  VKSearchItem.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKSearchItem: Decodable {
    let ownerID: Int
    let date: Date
    let text: String
    let attachments: [VKAttachment]?
    let comments: VKFeedItemComment
    let likes: VKFeedItemLike
    let reposts: VKFeedItemRepost
    let views: VKFeedItemView?

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
    }
}
