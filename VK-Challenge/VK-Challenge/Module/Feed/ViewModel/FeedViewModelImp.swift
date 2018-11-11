//
//  FeedViewModelImp.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import CoreText
import UIKit

final class FeedViewModelImp: FeedViewModel {
    // MARK: - Output

    var onAvatarLoaded: ((UIImage?) -> Void)?

    var onItemsReloaded: (([FeedCellViewModel]) -> Void)?

    var onNewItemsLoaded: (([FeedCellViewModel]) -> Void)?

    // MARK: - Members

    private let profileService: ProfileService

    private let feedService: FeedService

    private let imageLoader: ImageLoader

    private let textManager: FeedCellTextManager

    // MARK: - Private

    private let staticCellHeight: CGFloat = 64 + 44

    private var nextPageToken: String?

    private var isReloadingData = false

    // MARK: - Init

    init(profileService: ProfileService,
         feedService: FeedService,
         imageLoader: ImageLoader) {
        self.profileService = profileService
        self.feedService = feedService
        self.imageLoader = imageLoader
        textManager = FeedCellTextManager()

        loadInitialData()
    }

    // MARK: - Methods

    func reloadData(with currentLoadedData: [FeedCellViewModel]) {
        guard !isReloadingData else { return }
        isReloadingData = true

        feedService.getNews { response in
            let newCells = self.makeCellViewModels(from: response)
            let updatedCells = self.mergePostsReload(oldData: currentLoadedData, newData: newCells)

            DispatchQueue.main.async {
                self.onItemsReloaded?(updatedCells)
                self.isReloadingData = false
            }
        }
    }

    func loadNextPage() {
        guard let token = nextPageToken else { return }

        feedService.getNextPage(token: token) { response in
            self.handleNewPosts(response)
        }
    }

    private func loadInitialData() {
        profileService.getMyProfile(completion: loadMyAvatar)
        loadPosts()
    }

    private func loadMyAvatar(from profile: VKProfileModel) {
        imageLoader.load(from: profile.avatarURL100) { avatar in
            self.onAvatarLoaded?(avatar)
        }
    }

    private func loadPosts() {
        feedService.getNews { response in
            self.handleNewPosts(response)
        }
    }

    private func handleNewPosts(_ response: VKFeedResponseModel) {
        let cells = makeCellViewModels(from: response)
        nextPageToken = response.next

        DispatchQueue.main.async {
            self.onNewItemsLoaded?(cells)
        }
    }

    private func mergePostsReload(oldData: [FeedCellViewModel], newData: [FeedCellViewModel]) -> [FeedCellViewModel] {
        var postIdsToUpdate = Set<Int>()
        let cellsToUpdate = newData.filter { (newCell: FeedCellViewModel) -> Bool in
            let shouldUpdate = oldData.contains(where: { $0.postID == newCell.postID })
            if shouldUpdate {
                postIdsToUpdate.insert(newCell.postID)
            }

            return shouldUpdate
        }

        let cellsToInsert = newData.filter { (newCell: FeedCellViewModel) -> Bool in
            return !oldData.contains(where: { $0.postID == newCell.postID })
        }

        var merged = cellsToInsert + oldData
        for (idx, cell) in merged.enumerated() {
            let thisPostId = cell.postID
            if postIdsToUpdate.contains(thisPostId) {
                if let cellToReplace = cellsToUpdate.first(where: { $0.postID == thisPostId }) {
                    merged[idx] = cellToReplace
                }
            }
        }

        return merged
    }

    // MARK: - Helpers

    private func makeCellViewModels(from response: VKFeedResponseModel) -> [FeedCellViewModel] {
        var result = [FeedCellViewModel]()

        for item in response.items {
            let (title, avatar) = getTitleAndAvatar(for: item.sourceID, in: response.profiles, groups: response.groups)
            let (fullText, shortText, fullHeight, shortHeight) = textManager.makeTextToDisplay(from: item.text)

            let photos = item.attachmentsOrEmpty
                .compactMap { $0.photo }
                .compactMap { $0.displayableSize }

            var photoHeight: CGFloat = 0
            var photoUrls = [String]()

            if let photo = photos.first, photos.count == 1 {
                photoHeight = CGFloat(photo.height)
                photoUrls.append(photo.url)
            }

            var shortHeightValue: CGFloat?
            if let shortValue = shortHeight {
                shortHeightValue = shortValue + staticCellHeight + photoHeight
            }

            let viewModel = FeedCellViewModel(postID: item.postID, titleText: title,
                                              dateText: item.date.humanString,
                                              contentText: fullText, shortText: shortText,
                                              avatarURL: avatar, imageLoader: imageLoader,
                                              postImages: photoUrls,
                                              photoHeight: photoHeight,
                                              likesCount: item.likes.count,
                                              commentsCount: item.comments.count,
                                              repostCount: item.reposts.count,
                                              viewsCount: item.views?.count,
                                              contentHeight: fullHeight + staticCellHeight + photoHeight,
                                              shortContentHeight: shortHeightValue)

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
}

private final class FeedCellTextManager {
    // MARK: - Members

    private let foldableLinesNumber = 6

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

    func makeTextToDisplay(from string: String) -> (NSAttributedString, NSAttributedString?, CGFloat, CGFloat?) {
        let styledText = makeStyledText(from: string)
        let styledTextHeight = getTextHeight(styledText)

        guard styledTextHeight <= maxTextHeight else {
            let shortText = getShortText(from: styledText)
            let shortTextHeight = getTextHeightCF(shortText)

            return (styledText, shortText, styledTextHeight, shortTextHeight)
        }

        return (styledText, nil, styledTextHeight, nil)
    }

    // MARK: - Helpers

    private func makeStyledText(from string: String) -> NSAttributedString {
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: styledText.range)
        styledText.addAttribute(.font, value: textFont, range: styledText.range)

        return styledText
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

    private func getTextHeightCF(_ text: NSAttributedString) -> CGFloat {
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let frame = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, text.CFRange, nil, maxFrame, nil)

        return ceil(frame.height) + 3
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
