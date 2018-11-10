//
//  VKProfileModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKProfileModel: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatarURL100: String
}

extension VKProfileModel {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL100 = "photo_100"
    }
}

struct VKGroupModel: Decodable {
    let id: Int
    let name: String
    let avatarURL100: String
}

extension VKGroupModel {
    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarURL100 = "photo_100"
    }
}

// ==

struct VKFeedResponseModel: Decodable {
    let items: [VKFeedItem]
    let profiles: [VKProfileModel]
    let groups: [VKGroupModel]
    let next: String
}

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
    let views: VKFeedItemView
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

extension VKFeedResponseModel {
    enum CodingKeys: String, CodingKey {
        case items, profiles, groups
        case next = "next_from"
    }
}
