//
//  FeedViewModelImp.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import CoreText
import UIKit

protocol FeedViewModelOutput: class {
    var onAvatarLoaded: ((UIImage?) -> Void)? { get set }

    var onNewItemsLoaded: (([FeedCellViewModel]) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func loadInitialData()
}

final class FeedViewModelImp: FeedViewModel {
    // MARK: - Output

    var onAvatarLoaded: ((UIImage?) -> Void)?

    var onNewItemsLoaded: (([FeedCellViewModel]) -> Void)?

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
        loadPosts()

        let test = "Одной из ключевых ценностей ВКонтакте является то, что здесь сосредоточено огромное количество уникального контента. Сотни тысяч авторов и пабликов ежедневно создают миллионы материалов, которые невозможно найти нигде, кроме ВКонтакте. Здесь бы добавить немного текста чтобы его начало хватать на 8 строк но кто же знает когда жто начнется. Так вот и пишу я и код свой и  челлендж и много всего другого...."
        textManager.makeTextToDisplay(from: test)
    }

    private func loadMyAvatar(from profile: VKProfileModel) {
        imageLoader.load(from: profile.avatarURL100) { avatar in
            DispatchQueue.main.async { self.onAvatarLoaded?(avatar) }
        }
    }

    private func loadPosts() {
        let str = "Читатель Спарка напоминает, как стоит относиться к бизнес-литературе. \n\nБизнес-литература дает лишь общие теоретические знания, от которых нет практической пользы, и пользоваться ей стоит как учебником.\nhttps://spark.ru/startup/the-red-button/blog/32894/pochemu-biznes-literatura-bespolezna-na-90"

        let text = textManager.makeTextToDisplay(from: str)
        let content = FeedCellViewModel(contentText: text)

        DispatchQueue.main.async {
            self.onNewItemsLoaded?([content])
        }

        return;

        feedService.getNews { items in
//            let content = items.map { $0.text }
//                .map { self.textManager.makeTextToDisplay(from: $0) }
//                .compactMap { FeedCellViewModel(contentText: $0) }
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
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: NSMakeRange(0, styledText.length))

        guard getTextHeight(styledText) <= maxTextHeight else {
            // return makeClippedText(from: string)
            return getShortText(from: styledText)
        }

        return styledText
    }

    // MARK: - Helpers

    private func makeClippedText(from string: String) -> NSAttributedString {
        let tail = "\nПоказать полностью…"

        return NSAttributedString(string: "")
    }

    private func getTextHeight(_ text: NSAttributedString) -> CGFloat {
        let t2 = text.string.boundingRect(with: maxFrame, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: textFont, .paragraphStyle: textPragraphStyle], context: nil)

        let result = text.boundingRect(with: maxFrame,
                                       options: .usesLineFragmentOrigin,
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

    // ====

    let foldableLinesNumber = 6

    private func getShortText(from string: NSAttributedString) -> NSAttributedString {
        let typeSetter = CTTypesetterCreateWithAttributedString(string)

        var breakAt = 0
        for _ in 0 ..< foldableLinesNumber {
            breakAt += CTTypesetterSuggestLineBreak(typeSetter, breakAt, Double(maxFrame.width))
        }
        let linesText = string.attributedSubstring(from: NSRange(location: 0, length: breakAt))
        let mutable = NSMutableAttributedString(attributedString: linesText)
        mutable.append("\nПоказать полностью...".nsString)

        return mutable
    }

    private func textHeight(_ text: NSAttributedString) -> CGFloat {
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let frame = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, text.CFRange, nil, maxFrame, nil)

        return frame.height
    }
}

private extension String {
    var nsString: NSAttributedString {
        return NSAttributedString(string: self)
    }
}

private extension NSAttributedString {
    var CFRange: CFRange {
        return CFRangeMake(0, length)
    }
}
