//
//  VKAPIFeedField.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum VKAPIFeedField: RequestField {
    case filters
    case fields
    case startFrom
}

extension VKAPIFeedField {
    var value: String {
        switch self {
        case .filters:
            return "filters"
        case .fields:
            return "fields"
        case .startFrom:
            return "start_from"
        }
    }
}
