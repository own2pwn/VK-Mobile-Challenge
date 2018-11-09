//
//  VKAPIProfileService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class MyProfileService {
    // MARK: - Members

    private let api: VKAPIProfileService

    // MARK: - Interface

    func getMyProfile(completion: @escaping ((VKProfileModel) -> Void)) {
        api.getArray(.usersGet, fields: [.photo100]) { (r: [VKProfileModel]) in
            if let me = r.first { completion(me) }
        }
    }

    // MARK: - Init

    init(api: VKAPIProfileService) {
        self.api = api
    }
}
