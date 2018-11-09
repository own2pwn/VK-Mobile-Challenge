//
//  Router.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

enum AppModule {
    case feed
}

final class Router {
    // MARK: - Members

    private static let mainStoryboard: UIStoryboard = {
        UIStoryboard(name: "Main", bundle: nil)
    }()

    // MARK: - Interface

    static func replace(with module: AppModule) {
        guard let mainWindow = UIApplication.shared.keyWindow else { return }

        let controller = viewController(from: module)
        mainWindow.rootViewController = controller
    }

    // MARK: - Helpers

    private static func viewController(from module: AppModule) -> UIViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: module.storyboardID)
    }
}

private extension AppModule {
    var storyboardID: String {
        switch self {
        case .feed:
            return "Feed"
        }
    }
}
