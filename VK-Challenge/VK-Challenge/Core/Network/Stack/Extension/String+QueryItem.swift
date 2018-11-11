//
//  String+QueryItem.swift
//  NetworkStack
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

extension String: RequestField, RequestFieldValue {
    public var value: String {
        return self
    }
}
