//
//  Dependency.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class Dependency {
    // MARK: - Interface

    static func makeAuthViewModel() -> AuthControllerViewModel {
        let viewModel = AuthControllerViewModelImp(authService: authService)

        return viewModel
    }

    // MARK: - Instance

    private static let tokenStore = TokenStore()

    private static let authService: AuthService = {
        let service = AuthServiceImp(store: tokenStore)

        return service
    }()
}
