//
//  VKAPIFieldValue.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIFieldValue: RequestFieldValue {
    case api_latest

    case post

    case photo100
}

extension VKAPIFieldValue {
    var value: String {
        switch self {
        case .api_latest:
            return "5.87"

        case .post:
            return "post"

        case .photo100:
            return "photo_100"
        }
    }
}
