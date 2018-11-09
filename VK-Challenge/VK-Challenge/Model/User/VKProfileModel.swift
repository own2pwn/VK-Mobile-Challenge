//
//  VKProfileModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKProfileModel: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatarURL100: String
}

extension VKProfileModel {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL100 = "photo_100"
    }
}
