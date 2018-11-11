//
//  VKSearchResponseModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKSearchResponseModel: Decodable {
    let items: [VKSearchItem]
    let profiles: [VKProfileModel]
    let groups: [VKGroupModel]
    let next: String?
}

extension VKSearchResponseModel {
    enum CodingKeys: String, CodingKey {
        case items, profiles, groups
        case next = "next_from"
    }
}
