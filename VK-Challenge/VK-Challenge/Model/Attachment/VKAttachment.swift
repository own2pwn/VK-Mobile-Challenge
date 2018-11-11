//
//  VKAttachment.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKAttachment: Decodable {
    let type: String
    let photo: VKAttachmentPhoto?
}
