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

    var onSearchResultLoaded: (([FeedCellViewModel]) -> Void)?

    var onNewSearchItemsLoaded: (([FeedCellViewModel]) -> Void)?

    // MARK: - Members

    private let profileService: ProfileService

    private let feedService: FeedService

    private let imageLoader: ImageLoader

    private let textManager: FeedCellTextManager

    // MARK: - Private

    private let staticCellHeight: CGFloat = 64 + 44

    private let cardWidth = (UIScreen.main.bounds.width - 16)

    private var nextPageToken: String?

    private var nextSearchPageToken: String?

    private var lastSearchQuery: String?

    private var isReloadingData = false

    private var isLoadingSearch = false

    private var isLoadingNextPage = false

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

    private func loadInitialData() {
        profileService.getMyProfile(completion: loadMyAvatar)
        loadPosts()
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

    func reloadSearchData(with currentLoadedData: [FeedCellViewModel]) {
        guard
            !isReloadingData,
            let query = lastSearchQuery else { return }

        isReloadingData = true
        feedService.search(query) { response in
            let newCells = self.makeCellViewModels(from: response, highlight: query)
            let updatedCells = self.mergePostsReload(oldData: currentLoadedData, newData: newCells)

            DispatchQueue.main.async {
                self.onSearchResultLoaded?(updatedCells)
                self.isReloadingData = false
            }
        }
    }

    func loadNextPage() {
        guard
            !isLoadingNextPage,
            let token = nextPageToken else { return }

        isLoadingNextPage = true

        feedService.getNextPage(token: token) { response in
            self.isLoadingNextPage = false
            self.handleNewPosts(response)
        }
    }

    func loadNextSearchPage() {
        guard
            !isLoadingNextPage,
            let token = nextSearchPageToken,
            let query = lastSearchQuery else { return }

        isLoadingNextPage = true
        feedService.getNextSearchPage(token: token, searchText: query) { response in
            self.isLoadingNextPage = false
            self.handleNewSearch(response, query: query)
        }
    }

    func search(_ searchText: String?) {
        guard let searchText = searchText else {
            lastSearchQuery = nil
            return
        }

        guard
            !isLoadingSearch,
            !searchText.isEmpty,
            searchText != lastSearchQuery else { return }

        isLoadingSearch = true
        lastSearchQuery = searchText

        feedService.search(searchText) { response in
            self.isLoadingSearch = false
            self.nextSearchPageToken = response.next

            let cells = self.makeCellViewModels(from: response, highlight: searchText)
            DispatchQueue.main.async {
                self.onSearchResultLoaded?(cells)
            }
        }
    }

    // MARK: - Private

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
}

// MARK: - Search

private extension FeedViewModelImp {
    private func handleNewSearch(_ response: VKSearchResponseModel, query: String) {
        let cells = makeCellViewModels(from: response, highlight: query)
        nextSearchPageToken = response.next

        DispatchQueue.main.async {
            self.onNewSearchItemsLoaded?(cells)
        }
    }

    private func makeCellViewModels(from response: VKSearchResponseModel, highlight partToHighlight: String) -> [FeedCellViewModel] {
        var result = [FeedCellViewModel]()

        for item in response.items {
            let (title, avatar) = getTitleAndAvatar(for: item.sourceID, in: response.profiles, groups: response.groups)
            let (fullText, shortText, fullHeight, shortHeight)
                = textManager.makeTextToDisplay(from: item.text, highlight: partToHighlight)

            let photos = getPhotos(from: item)
            let maxPhotoHeight = getMaxPhotoHeight(from: photos)
            let carouselMargin = getCarouselMargin(from: photos)
            let photoUrls = photos.map { $0.url }

            var shortHeightValue: CGFloat?
            if let shortValue = shortHeight {
                shortHeightValue = shortValue + staticCellHeight
                    + maxPhotoHeight + carouselMargin
            }

            let contentHeight: CGFloat = fullHeight + staticCellHeight
                + maxPhotoHeight + carouselMargin

            let viewModel = FeedCellViewModel(postID: item.sourceID, titleText: title,
                                              dateText: item.date.humanString,
                                              contentText: fullText, shortText: shortText,
                                              avatarURL: avatar, imageLoader: imageLoader,
                                              postImages: photoUrls,
                                              photoHeight: maxPhotoHeight,
                                              likesCount: item.likes.count,
                                              commentsCount: item.comments.count,
                                              repostCount: item.reposts.count,
                                              viewsCount: item.views?.count,
                                              contentHeight: contentHeight,
                                              shortContentHeight: shortHeightValue)

            result.append(viewModel)
        }

        return result
    }
}

// MARK: - Feed Reload

private extension FeedViewModelImp {
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
}

// MARK: - Cell ViewModel

private extension FeedViewModelImp {
    private func makeCellViewModels(from response: VKFeedResponseModel) -> [FeedCellViewModel] {
        var result = [FeedCellViewModel]()

        for item in response.items {
            let (title, avatar) = getTitleAndAvatar(for: item.sourceID, in: response.profiles, groups: response.groups)
            let (fullText, shortText, fullHeight, shortHeight) = textManager.makeTextToDisplay(from: item.text)

            let photos = getPhotos(from: item)
            let maxPhotoHeight = getMaxPhotoHeight(from: photos)
            let carouselMargin = getCarouselMargin(from: photos)
            let photoUrls = photos.map { $0.url }

            var shortHeightValue: CGFloat?
            if let shortValue = shortHeight {
                shortHeightValue = shortValue + staticCellHeight
                    + maxPhotoHeight + carouselMargin
            }

            let contentHeight: CGFloat = fullHeight + staticCellHeight
                + maxPhotoHeight + carouselMargin

            let viewModel = FeedCellViewModel(postID: item.postID, titleText: title,
                                              dateText: item.date.humanString,
                                              contentText: fullText, shortText: shortText,
                                              avatarURL: avatar, imageLoader: imageLoader,
                                              postImages: photoUrls,
                                              photoHeight: maxPhotoHeight,
                                              likesCount: item.likes.count,
                                              commentsCount: item.comments.count,
                                              repostCount: item.reposts.count,
                                              viewsCount: item.views?.count,
                                              contentHeight: contentHeight,
                                              shortContentHeight: shortHeightValue)

            result.append(viewModel)
        }

        return result
    }

    private func getPhotos(from item: VKModelWithAttachment) -> [VKAttachmentPhotoSize] {
        let photos = item.attachmentsOrEmpty
            .compactMap { $0.photo }
            .compactMap { $0.displayableSize }

        return photos
    }

    private func getMaxPhotoHeight(from photos: [VKAttachmentPhotoSize]) -> CGFloat {
        guard !photos.isEmpty else { return 0 }
        if photos.count == 1 {
            return getPhotoHeight(photos[0])
        }
        let heights = photos.map { getPhotoHeightCarousel($0) }

        return heights.max()!
    }

    private func getPhotoHeight(_ photo: VKAttachmentPhotoSize) -> CGFloat {
        let fHeight = CGFloat(photo.height)
        let fWidth = CGFloat(photo.width)
        let ratio = fWidth / fHeight

        let photoHeight = cardWidth / ratio

        return photoHeight
    }

    private func getPhotoHeightCarousel(_ photo: VKAttachmentPhotoSize) -> CGFloat {
        let fHeight = CGFloat(photo.height)
        let fWidth = CGFloat(photo.width)
        let ratio = fWidth / fHeight

        let photoHeight = (cardWidth - 28) / ratio

        return photoHeight
    }

    private func getCarouselMargin(from photos: [VKAttachmentPhotoSize]) -> CGFloat {
        return photos.count > 1 ? 38 : 0
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
        return ("-none-", "-none-")
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

    func makeTextToDisplay(from string: String, highlight partToHighlight: String) -> (NSAttributedString, NSAttributedString?, CGFloat, CGFloat?) {
        let styledText = makeStyledText(from: string, highlight: partToHighlight)
        let styledTextHeight = getTextHeight(styledText)

        guard styledTextHeight <= maxTextHeight else {
            let shortText = getShortText(from: styledText)
            let shortTextHeight = getTextHeightCF(shortText)

            return (styledText, shortText, styledTextHeight, shortTextHeight)
        }

        return (styledText, nil, styledTextHeight, nil)
    }

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

    private func makeStyledText(from string: String, highlight partToHighlight: String) -> NSAttributedString {
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: styledText.nsRange)
        styledText.addAttribute(.font, value: textFont, range: styledText.nsRange)

        if let rangeToHighlight = string.range(of: partToHighlight, options: .caseInsensitive) {
            let highlightRange = NSRange(rangeToHighlight, in: string)
            let highlightColor = UIColor.rgb(255, 160, 0).withAlphaComponent(0.12)

            styledText.addAttribute(.backgroundColor, value: highlightColor, range: highlightRange)
        }

        return styledText
    }

    private func makeStyledText(from string: String) -> NSAttributedString {
        let styledText = NSMutableAttributedString(string: string)
        styledText.addAttribute(.paragraphStyle, value: textPragraphStyle, range: styledText.nsRange)
        styledText.addAttribute(.font, value: textFont, range: styledText.nsRange)

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
        mutable.addAttribute(.paragraphStyle, value: textPragraphStyle, range: mutable.nsRange)

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

    var nsRange: NSRange {
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
