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
    }

    private func loadMyAvatar(from profile: VKProfileModel) {
        imageLoader.load(from: profile.avatarURL100) { avatar in
            self.onAvatarLoaded?(avatar)
        }
    }

    private func loadPosts() {
        let str = "Читатель Спарка напоминает, как стоит относиться к бизнес-литературе. \n\nБизнес-литература дает лишь общие теоретические знания, от которых нет практической пользы, и пользоваться ей стоит как учебником.\nhttps://spark.ru/startup/the-red-button/blog/32894/pochemu-biznes-literatura-bespolezna-na-90"

        let text = textManager.makeTextToDisplay(from: str)
        // let content = FeedCellViewModel(contentText: text)

//        DispatchQueue.main.async {
//            self.onNewItemsLoaded?([content])
//        }

        feedService.getNews { response in
            let cells = self.makeCellViewModels(from: response)

            DispatchQueue.main.async {
                self.onNewItemsLoaded?(cells)
            }
        }
    }

    private func makeCellViewModels(from response: VKFeedResponseModel) -> [FeedCellViewModel] {
        var result = [FeedCellViewModel]()

        for item in response.items {
            let (title, avatar) = getTitleAndAvatar(for: item.sourceID, in: response.profiles, groups: response.groups)
            let (full, short) = textManager.makeTextToDisplay(from: item.text)

            let viewModel = FeedCellViewModel(titleText: title, dateText: item.date.humanString,
                                              contentText: full, shortText: short,
                                              avatarURL: avatar, imageLoader: imageLoader)

            result.append(viewModel)
        }

        return result
    }

    private func getTitleAndAvatar(for id: Int, in profiles: [VKProfileModel], groups: [VKGroupModel]) -> (String, String) {
        let valueToFind = abs(id)
        if let profile = profiles.first(where: { $0.id == valueToFind }) {
            let name = "\(profile.firstName) \(profile.lastName)"
            return (name, profile.avatarURL100)
        }
        if let group = groups.first(where: { $0.id == valueToFind }) {
            return (group.name, group.avatarURL100)
        }

        assertionFailure()
        return ("", "")
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

    func makeTextToDisplay(from string: String) -> (NSAttributedString, NSAttributedString?) {
        let styledText = makeStyledText(from: string)
        let styledTextHeight = textHeight(styledText)

        if getTextHeight(styledText) != styledTextHeight, !string.isEmpty {
            let diff = getTextHeight(styledText) - styledTextHeight
            print("^ there's a diff [\(diff)]")
            // print("^ for [\(string)] getTextHeight => \(getTextHeight(styledText)) | while [\(styledTextHeight)]")
        }

        guard styledTextHeight <= maxTextHeight else {
            // return makeClippedText(from: string)
            return (styledText, getShortText(from: styledText))
        }

        return (styledText, nil)
    }

    // MARK: - Helpers

    private func makeStyledText(from string: String) -> NSAttributedString {
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: styledText.range)
        styledText.addAttribute(.font, value: textFont, range: styledText.range)
        // styledText.addAttribute(.foregroundColor, value: UIColor.green, range: styledText.range)

        return styledText
    }

    private func makeClippedText(from string: String) -> NSAttributedString {
        let tail = "\nПоказать полностью…"

        return NSAttributedString(string: "")
    }

    private func getTextHeight(_ text: NSAttributedString) -> CGFloat {
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

        let showMoreText = "\nПоказать полностью..."
        let showMoreLen = showMoreText.count - 1

        mutable.append(showMoreText.nsString)
        mutable.addAttribute(.paragraphStyle, value: textPragraphStyle, range: mutable.range)

        let showMoreFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let showMoreRange = NSMakeRange(mutable.length - showMoreLen, showMoreLen)
        let showMoreColor = UIColor.rgb(82, 139, 204)

        mutable.addAttribute(.font, value: showMoreFont, range: showMoreRange)
        mutable.addAttribute(.foregroundColor, value: showMoreColor, range: showMoreRange)

        return mutable
    }

    private func textHeight(_ text: NSAttributedString) -> CGFloat {
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let frame = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, text.CFRange, nil, maxFrame, nil)

        return ceil(frame.height)
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

    var range: NSRange {
        return NSMakeRange(0, length)
    }
}

private extension Date {
    var humanString: String {
        let cal = Calendar.current
        let fmt = DateFormatter()

        if cal.isDateInThisYear(self) {
            fmt.dateFormat = "d MMM в HH:mm"
        } else {
            fmt.dateFormat = "d MMM yyyy"
        }
        return fmt.string(from: self)
    }
}

public extension Calendar {
    public func isDateInThisYear(_ date: Date) -> Bool {
        return compare(Date(), to: date, toGranularity: .year) == .orderedSame
    }
}
