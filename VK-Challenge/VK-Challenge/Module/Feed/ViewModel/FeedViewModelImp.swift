//
//  FeedViewModelImp.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol FeedViewModelOutput: class {
    var onAvatarLoaded: ((UIImage?) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func loadInitialData()
}

final class FeedViewModelImp: FeedViewModel {
    // MARK: - Output

    var onAvatarLoaded: ((UIImage?) -> Void)?

    // MARK: - Members

    private let profileService: MyProfileService

    private let feedService: FeedService

    private let imageLoader: ImageLoader

    private let textManager: FeedCellTextManager

    // MARK: - Init

    init(profileService: MyProfileService,
         feedService: FeedService,
         imageLoader: ImageLoader) {
        self.profileService = profileService
        self.feedService = feedService
        self.imageLoader = imageLoader
        textManager = FeedCellTextManager()

        loadInitialData()
    }

    // MARK: - Methods

    func loadInitialData() {
        profileService.getMyProfile(completion: loadMyAvatar)
    }

    private func loadMyAvatar(from profile: VKProfileModel) {
        imageLoader.load(from: profile.avatarURL100) { avatar in
            DispatchQueue.main.async { self.onAvatarLoaded?(avatar) }
        }
    }

    func kek() {
        let s = TokenStore()
        let t = s.get()!
        let f = VKAPIFactory(token: t)
        let ss = FeedService(api: f.makeFeedService())

        ss.getNews { _ in
            DispatchQueue.main.async {
                // self.items.append(contentsOf: items)
                // self.postCollection.reloadData()
            }
        }
    }

    // MARK: - Text width

    // private lazy var maxText = <#value#>

    private func processNewItems(_ items: [VKFeedItem]) {}
}

private final class FeedCellTextManager {
    // MARK: - Members

    private var textFont = UIFont.systemFont(ofSize: 15)

    private lazy var textPragraphStyle: NSParagraphStyle = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        return paragraph
    }()

    private lazy var maxFrame: CGSize = {
        let maxWidth = UIScreen.main.bounds.width - 40
        let maxFrame = CGSize(width: maxWidth, height: 0)

        return maxFrame
    }()

    private lazy var maxTextHeight = getTextMaxHeight()

    // MARK: - Interface

    func makeTextToDisplay(from string: String) -> NSAttributedString {
        guard getTextHeight(string) <= maxTextHeight else {
            return makeClippedText(from: string)
        }
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: NSMakeRange(0, styledText.length))

        return styledText
    }

    // MARK: - Helpers

    private func makeClippedText(from string: String) -> NSAttributedString {
        let tail = "\nПоказать полностью…"

        ctframe
    }

    private func getTextHeight(_ text: String) -> CGFloat {
        let result = text.boundingRect(with: maxFrame, options: .usesLineFragmentOrigin,
                                       attributes: [.font: textFont, .paragraphStyle: textPragraphStyle],
                                       context: nil)

        return ceil(result.height)
    }

    private func getTextMaxHeight() -> CGFloat {
        let maxLines = 8
        let dummy = String(repeating: "\n", count: maxLines)

        let result = dummy.boundingRect(with: maxFrame, options: .usesLineFragmentOrigin,
                                        attributes: [.font: textFont, .paragraphStyle: textPragraphStyle],
                                        context: nil)

        return ceil(result.height)
    }
}
