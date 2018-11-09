//
//  Constants.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation
import UIKit

enum CONST {
    enum VK {
        static let appID = "6746442"

        static let apiVersion = "5.87"

        static let authScope: [VKScope] = [.friends, .photos, .wall, .offline]

        static let apiEndpoint = "https://api.vk.com/method/"
    }
}
