//
//  VKAPIResponse.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKAPIArrayResponse<M: Decodable>: Decodable {
    let response: [M]
}

struct VKAPIResponse<M: Decodable>: Decodable {
    let response: M
}
