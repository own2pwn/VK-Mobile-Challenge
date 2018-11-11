//
//  AuthService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation
import VK_ios_sdk

typealias VK_SDK = VKSdk
typealias VKAuthCallback = ((Bool, String?) -> Void)

protocol AuthService: AuthServiceOutput {
    func authorize(with scope: [VKScope], completion: @escaping VKAuthCallback)

    func checkIfAuthorized(with scope: [VKScope], completion: @escaping VKAuthCallback)
}

protocol AuthServiceOutput: class {
    var onNeedPresent: ((UIViewController) -> Void)? { get set }
}
