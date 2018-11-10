//
//  VKGroupModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKGroupModel: Decodable {
    let id: Int
    let name: String
    let avatarURL100: String
}

extension VKGroupModel {
    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarURL100 = "photo_100"
    }
}
