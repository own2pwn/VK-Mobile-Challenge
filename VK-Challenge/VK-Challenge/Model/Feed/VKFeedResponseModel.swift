//
//  VKFeedResponseModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKFeedResponseModel: Decodable {
    let items: [VKFeedItem]
    let profiles: [VKProfileModel]
    let groups: [VKGroupModel]
    let next: String
}

extension VKFeedResponseModel {
    enum CodingKeys: String, CodingKey {
        case items, profiles, groups
        case next = "next_from"
    }
}
