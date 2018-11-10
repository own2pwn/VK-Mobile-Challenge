//
//  VKAPIField.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIField: RequestField {
    case version
    case token
}

extension VKAPIField {
    var value: String {
        switch self {
        case .version:
            return "v"
        case .token:
            return "access_token"
        }
    }
}
