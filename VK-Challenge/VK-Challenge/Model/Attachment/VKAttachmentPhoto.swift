//
//  VKAttachmentPhoto.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKAttachmentPhoto: Decodable {
    let id: Int
    let ownerID: Int
    let sizes: [VKAttachmentPhotoSize]
    let text: String
    let date: Date
    let postID: Int?
}

extension VKAttachmentPhoto {
    var displayableSize: VKAttachmentPhotoSize? {
        return sizes.first(where: { $0.type == "x" })
    }
}

struct VKAttachmentPhotoSize: Decodable {
    let type: String
    let url: String
    let width: Int
    let height: Int
}

extension VKAttachmentPhoto {
    enum CodingKeys: String, CodingKey {
        case id, sizes, text
        case date

        case ownerID = "owner_id"
        case postID = "post_id"
    }
}
