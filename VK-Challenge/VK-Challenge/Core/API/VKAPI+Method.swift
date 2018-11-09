//
//  VKAPI+Method.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIMethodUsers {
    case get
}

extension VKAPIMethodUsers: VKAPIMethod {
    var value: String {
        switch self {
        case .get:
            return "users.get"
        }
    }
}

enum VKAPIUsersField {
    case photo100
}

extension VKAPIUsersField: VKAPIField {
    var value: String {
        switch self {
        case .photo100:
            return "photo_100"
        }
    }
}
