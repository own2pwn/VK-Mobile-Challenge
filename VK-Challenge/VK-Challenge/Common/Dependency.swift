//
//  Dependency.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

final class Dependency {
    // MARK: - Auth

    static func makeAuthViewModel() -> AuthControllerViewModel {
        let service = makeAuthService()
        let viewModel = AuthControllerViewModelImp(authService: service)

        return viewModel
    }

    static func makeFeedViewModel() -> FeedViewModel {
        let service = makeMyProfileService()
        let loader = makeImageLoader()
        let viewModel = FeedViewModelImp(profileService: service, imageLoader: loader)

        return viewModel
    }

    // MARK: - Private

    private static func makeImageLoader() -> ImageLoader {
        let loader = ImageLoader()

        return loader
    }

    private static func makeMyProfileService() -> MyProfileService {
        let apiService = vkAPIFactory.makeProfileService()

        return MyProfileService(api: apiService)
    }

    private static func makeAuthService() -> AuthService {
        let service = AuthServiceImp(store: tokenStore)

        return service
    }

    // MARK: - Instance

    private static let vkAPIFactory: VKAPIFactory = {
        let token = tokenStore.get()!

        return VKAPIFactory(token: token)
    }()

    private static let tokenStore = TokenStore()
}
