//
//  ViewController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

public typealias VK_SDK = VKSdk

final class ViewController: UIViewController {
    // MARK: - Outlets

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        initVK()
    }

    // MARK: - Members

    // MARK: - Methods

    private func initVK() {
        guard let vk = VK_SDK.initialize(withAppId: CONST.VK.appID) else {
            fatalError("^ can't init vk sdk!")
        }

        vk.register(self)
        vk.uiDelegate = self
    }

    private func authorize(with scope: [VKScope]) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    @IBAction
    private func testCode() {
        let scope: [VKScope] = [.friends, .photos, .wall, .offline]
        authorize(with: scope)
    }

    @IBAction
    private func testDeauth() {
        VK_SDK.forceLogout()
    }

    private func showFailedAuthAlert(with error: Error? = nil) {
        let alert = UIAlertController(title: "Authorization failed", message: error?.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

extension ViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        guard let token = result.token else {
            showFailedAuthAlert(with: result?.error)
            return
        }

        print("got [\(token)] | [\(VK_SDK.accessToken())]")
    }

    func vkSdkUserAuthorizationFailed() {
        assertionFailure()
    }
}

extension ViewController: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        assertionFailure(captchaError.errorMessage)
    }
}
