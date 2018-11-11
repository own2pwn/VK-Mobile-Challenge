//
//  VKAttachmentPhoto.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct VKAttachmentPhoto: Decodable {
    let sizes: [VKAttachmentPhotoSize]
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
