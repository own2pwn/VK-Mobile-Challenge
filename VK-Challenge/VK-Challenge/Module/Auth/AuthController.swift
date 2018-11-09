//
//  AuthController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

final class AuthController: UIViewController {
    // MARK: - Outlets

    @IBOutlet
    private var loginButton: UIButton!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    // MARK: - Members

    private lazy var viewModel = Dependency.makeAuthViewModel()

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.loginButtonEnabled = { [unowned self] isEnabled in
            self.loginButton.isEnabled = isEnabled
        }
        viewModel.onNeedPresent = { [unowned self] controller in
            self.present(controller, animated: true)
        }
        viewModel.onNeedShowError = { [unowned self] message in
            self.showError(with: message)
        }

        viewModel.onNeedShowFeed = { [unowned self] in
            self.showFeed()
        }
    }

    // MARK: - Helpers

    private func showError(with message: String? = nil) {
        let alert = UIAlertController(title: "Authorization failed", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    private func showFeed() {
        Router.replace(with: .feed)
    }

    // MARK: - Actions

    @IBAction
    private func authorize() {
        viewModel.authorize()
    }
}
