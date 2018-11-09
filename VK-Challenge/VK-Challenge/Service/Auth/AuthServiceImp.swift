//
//  AuthServiceImp.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

final class AuthServiceImp: NSObject, AuthService {
    // MARK: - Output

    var onNeedPresent: ((UIViewController) -> Void)?

    // MARK: - Interface

    func authorize(with scope: [VKScope], completion: @escaping VKAuthCallback) {
        authCallback = completion

        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    func checkIfAuthorized(with scope: [VKScope], completion: @escaping VKAuthCallback) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.wakeUpSession(perms) { state, err in
            if let e = err {
                completion(false, e.localizedDescription)
                self.store.reset()
                return
            }

            let isAuthorized = (state == VKAuthorizationState.authorized)
            completion(isAuthorized, nil)
            if !isAuthorized {
                self.store.reset()
            }
        }
    }

    // MARK: - Members

    private let store: TokenStore

    private var authCallback: VKAuthCallback?

    // MARK: - Init

    init(store: TokenStore) {
        self.store = store
        super.init()
        initSDK()
    }

    // MARK: - Private

    private func initSDK() {
        guard let vk = VK_SDK.initialize(withAppId: CONST.VK.appID) else {
            assertionFailure("^ can't init vk sdk!")
            return
        }

        vk.register(self)
        vk.uiDelegate = self
    }
}

extension AuthServiceImp: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        defer { authCallback = nil }

        guard let token = result.token.accessToken else {
            authCallback?(false, result?.error?.localizedDescription)
            store.reset()
            return
        }
        authCallback?(true, nil)
        store.save(token)
    }

    func vkSdkUserAuthorizationFailed() {
        authCallback?(false, nil)
        authCallback = nil
        store.reset()
    }
}

extension AuthServiceImp: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        onNeedPresent?(controller)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        authCallback?(false, captchaError?.errorMessage)
        authCallback = nil
        store.reset()
    }
}
