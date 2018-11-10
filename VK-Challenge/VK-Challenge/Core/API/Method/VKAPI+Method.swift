//
//  VKAPI+Method.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIMethodUsers {
    case usersGet
}

enum VKAPIMethodFeed {
    case feedGet
}

// === Filters

enum VKAPIFeedFilter {
    case post
}

// === Fields

enum VKAPIUsersField {
    case photo100
}

enum VKAPIFeedField {
    case count
    case from
    case photo100
}

extension VKAPIMethodUsers: VKAPIMethod {
    var value: String {
        switch self {
        case .usersGet:
            return "users.get"
        }
    }
}

extension VKAPIMethodFeed: VKAPIMethod {
    var value: String {
        switch self {
        case .feedGet:
            return "newsfeed.get"
        }
    }
}

// === Filters

extension VKAPIFeedFilter: VKAPIFilter {
    var value: String {
        switch self {
        case .post:
            return "post"
        }
    }
}

// === Fields

extension VKAPIUsersField: VKAPIField {
    var value: String {
        switch self {
        case .photo100:
            return "photo_100"
        }
    }
}

extension VKAPIFeedField: VKAPIField {
    var value: String {
        switch self {
        case .count:
            return "count"
        case .from:
            return "start_from"
        case .photo100:
            return "photo_100"
        }
    }
}
