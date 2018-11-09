//
//  FeedController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

final class FeedController: UIViewController {
    // MARK: - Outlets

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        let s = VKAPIProfileService()
        s.getMyProfile()
    }

    // MARK: - Members

    private let store: TokenStore = { TokenStore() }()

    // MARK: - Methods

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
        Router.replace(with: .auth)
    }

    private func showFailedAuthAlert(with error: Error? = nil) {
        let alert = UIAlertController(title: "Authorization failed", message: error?.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

// ===
