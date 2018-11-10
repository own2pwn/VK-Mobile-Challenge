//
//  VKAPIMethod.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIMethod: URLAdaptable {
    case usersGet
    case feedGet
}

extension VKAPIMethod {
    var value: String {
        switch self {
        case .usersGet:
            return "users.get"
        case .feedGet:
            return "newsfeed.get"
        }
    }
}
