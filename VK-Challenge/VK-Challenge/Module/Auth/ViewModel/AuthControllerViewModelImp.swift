//
//  AuthControllerViewModelImp.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

final class AuthControllerViewModelImp: AuthControllerViewModel {
    // MARK: - Output

    var loginButtonEnabled: ((Bool) -> Void)?

    var onNeedPresent: ((UIViewController) -> Void)?

    var onNeedShowError: ((String?) -> Void)?

    var onNeedShowFeed: VoidBlock?

    // MARK: - Members

    private let authService: AuthService

    private let authScope = CONST.VK.authScope

    // MARK: - Init

    init(authService: AuthService) {
        self.authService = authService

        setupLocalBind()
        checkIfAuthorized()
    }

    private func setupLocalBind() {
        authService.onNeedPresent = { [weak self] controller in
            self?.onNeedPresent?(controller)
        }
    }

    // MARK: - Interface

    func authorize() {
        authService.authorize(with: authScope, completion: handleAuthCallback)
    }

    // MARK: - Private

    private func checkIfAuthorized() {
        authService.checkIfAuthorized(with: authScope) { authorized, _ in
            DispatchQueue.main.async {
                if authorized {
                    self.onNeedShowFeed?()
                }

                self.loginButtonEnabled?(!authorized)
            }
        }
    }

    private func handleAuthCallback(_ isAuthorized: Bool, errorMessage: String?) {
        DispatchQueue.main.async {
            guard isAuthorized else {
                self.loginButtonEnabled?(true)
                self.onNeedShowError?(errorMessage)
                return
            }

            self.onNeedShowFeed?()
        }
    }
}
