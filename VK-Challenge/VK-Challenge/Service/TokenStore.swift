//
//  TokenStore.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class TokenStore {
    // MARK: - Members

    private let defaults = UserDefaults.standard

    // MARK: - Interface

    func reset() {
        defaults.set(nil, forKey: kTokenKey)
    }

    func save(_ token: String) {
        // we're not going use keychain coz lack of time
        defaults.set(token, forKey: kTokenKey)
    }

    func get() -> String? {
        let saved = defaults.value(forKey: kTokenKey) as? String

        return saved
    }

    // MARK: - Const

    private let kTokenKey = "kVKToken"
}
