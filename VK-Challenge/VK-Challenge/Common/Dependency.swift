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
        let profileService = makeMyProfileService()
        let loader = makeImageLoader()
        let feedService = makeFeedService()

        let viewModel = FeedViewModelImp(profileService: profileService,
                                         feedService: feedService,
                                         imageLoader: loader)

        return viewModel
    }

    // MARK: - Private

    private static func makeFeedService() -> FeedService {
        let apiService = vkAPIFactory.makeFeedService()

        return FeedService(api: apiService)
    }

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
        let token = tokenStore.get() ?? "non-valid"

        return VKAPIFactory(token: token)
    }()

    private static let tokenStore = TokenStore()
}
