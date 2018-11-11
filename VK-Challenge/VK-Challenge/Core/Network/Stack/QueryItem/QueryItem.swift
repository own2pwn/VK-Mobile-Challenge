//
//  QueryItem.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public struct QueryItem {
    let field: RequestField
    let values: [RequestFieldValue]
}

extension QueryItem {
    init(field: RequestField, value: RequestFieldValue) {
        self.field = field
        values = [value]
    }
}
