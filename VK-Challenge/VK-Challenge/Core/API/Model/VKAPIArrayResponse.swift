//
//  VKAPIArrayResponse.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKAPIArrayResponse<T: Decodable>: Decodable {
    let response: [T]
}
