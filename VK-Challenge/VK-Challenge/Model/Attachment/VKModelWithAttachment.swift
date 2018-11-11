//
//  VKModelWithAttachment.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

protocol VKModelWithAttachment {
    var attachmentsOrEmpty: [VKAttachment] { get }
}
