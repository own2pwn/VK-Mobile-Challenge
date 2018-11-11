//
//  Haptic.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

enum FeedbackStyle {
    case light
    case medium
    case heavy
}

final class Haptic {
    static func trigger(with style: FeedbackStyle) {
        guard #available(iOS 10.0, *) else { return }
        let generator = UIImpactFeedbackGenerator(style: style.hapticStyle)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Private

    private init() {}
}

@available(iOS 10.0, *)
private extension FeedbackStyle {
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        }
    }
}
