//
//  FeedController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

final class FeedController: UIViewController {
    // MARK: - Outlets

    @IBOutlet
    private var postCollection: UICollectionView!

    @IBOutlet
    private var postCollectionBottomConstraint: NSLayoutConstraint!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didAppear = true
    }

    // MARK: - Members

    private var datasource: [FeedCellViewModel] = []

    private let viewModel: FeedViewModel = { Dependency.makeFeedViewModel() }()

    // MARK: Cell Expand

    private var expandedIndexPath: IndexPath?

    private var isCellExpanded = false

    // MARK: P2R

    private let refreshThreshold: CGFloat = 150

    private var didAppear = false

    private var didReachRefreshThreshold = false

    // MARK: Footer

    private var didReachFooter = false

    private var hasMoreData = false

    // MARK: - Search

    private var searchDatasource: [FeedCellViewModel] = []

    private var shouldDisplaySearch = false

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.onAvatarLoaded = { [unowned self] avatar in
            self.updateAvatar(with: avatar)
        }
        viewModel.onNewItemsLoaded = { [unowned self] items, hasMoreData in
            self.datasource.append(contentsOf: items)
            self.updateFooter()
            self.didReachFooter = false
            self.hasMoreData = hasMoreData
            self.postCollection.reloadData()
        }
        viewModel.onItemsReloaded = { [unowned self] items, hasMoreData in
            self.datasource = items
            self.updateFooter()
            self.hasMoreData = hasMoreData
            self.didReachRefreshThreshold = false
            self.postCollection.reloadData()
        }
        viewModel.onSearchResultLoaded = { [unowned self] items, hasMoreData in
            self.searchDatasource = items
            self.shouldDisplaySearch = true
            self.updateFooter()
            self.hasMoreData = hasMoreData
            self.postCollection.reloadData()
        }
        viewModel.onSearchResultReloaded = { [unowned self] items, hasMoreData in
            self.searchDatasource = items
            self.updateFooter()
            self.hasMoreData = hasMoreData
            self.didReachRefreshThreshold = false
            self.postCollection.reloadData()
        }
        viewModel.onNewSearchItemsLoaded = { [unowned self] items, hasMoreData in
            self.searchDatasource.append(contentsOf: items)
            self.updateFooter()
            self.didReachFooter = false
            self.hasMoreData = hasMoreData
            self.postCollection.reloadData()
        }
        viewModel.hasMoreDataChanged = { [unowned self] value in
            self.hasMoreData = value
            if let footer = self.postCollection.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? FeedFooter {
                footer.setIsLoading(value)
            }
        }
    }

    private func setupCollectionView() {
        postCollection.contentInset.top = 24
        postCollection.contentInset.bottom = 64

        setupKeyboardHandling()
    }

    private func updateAvatar(with image: UIImage?) {
        feedHeader?.setAvatar(image)
    }

    private func updateFooter() {
        if let footer = feedFooter {
            updateFooterCount(footer)
            footer.setIsLoading(false)
        }
    }

    private func updateFooterCount(_ footer: FeedFooter) {
        let count = actualDatasource.count
        footer.setLoadedPostCount(count)
    }

    // MARK: - Keyboard

    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingInHeader))
        postCollection.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func endEditingInHeader() {
        feedHeader?.endEditing(true)
    }

    @objc
    private func onKeyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        postCollectionBottomConstraint.constant = keyboardFrame.size.height
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @objc
    private func onKeyboardWillHide() {
        postCollectionBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Helpers

private extension FeedController {
    var actualDatasource: [FeedCellViewModel] {
        return shouldDisplaySearch ? searchDatasource : datasource
    }

    var feedHeader: FeedHeader? {
        return postCollection.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? FeedHeader
    }

    var feedFooter: FeedFooter? {
        return postCollection.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? FeedFooter
    }
}

extension FeedController: FeedCellExpandDelegate {
    func cell(_ cell: UICollectionViewCell, wantsExpand: Bool) {
        expandedIndexPath = postCollection.indexPath(for: cell)
        isCellExpanded = wantsExpand
        postCollection.collectionViewLayout.invalidateLayout()
    }
}

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actualDatasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = getViewModel(at: indexPath)
        let cell: (AnyFeedCell & UICollectionViewCell)

        if model.postImages.count > 1 {
            cell = collectionView.dequeueReusableCell(ofType: FeedCellWithCarousel.self, at: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(ofType: FeedCell.self, at: indexPath)
        }

        let shouldExpand = indexPath == expandedIndexPath && isCellExpanded
        cell.setup(with: model, isExpanded: shouldExpand)
        cell.expandDelegate = self

        return cell
    }

    private func getViewModel(at indexPath: IndexPath) -> FeedCellViewModel {
        return actualDatasource[indexPath.row]
    }

    // MARK: - Header

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedHeader", for: indexPath) as! FeedHeader
            header.delegate = self

            return header
        }

        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FeedFooter", for: indexPath) as! FeedFooter

            return footer
        }

        return UICollectionReusableView()
    }

    // MARK: - Footer

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard
            let footer = view as? FeedFooter,
            elementKind == UICollectionView.elementKindSectionFooter else { return }

        if didAppear {
            updateFooterCount(footer)
        }
        guard hasMoreData else {
            return
        }

        if (shouldDisplaySearch && searchDatasource.isEmpty) || (!shouldDisplaySearch && datasource.isEmpty) {
            return
        }

        footer.setIsLoading(true)
        if !didReachFooter {
            Haptic.trigger(with: .medium)
            didReachFooter = true
        }

        if shouldDisplaySearch {
            viewModel.loadNextSearchPage()
        } else {
            viewModel.loadNextPage()
        }
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    // MARK: - Cell size

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.row < datasource.count else {
            return CGSize(width: collectionView.frame.width, height: 256)
        }

        let model = getViewModel(at: indexPath)
        let cellHeight = model.shortContentHeight ?? model.contentHeight

        if indexPath == expandedIndexPath, isCellExpanded {
            return CGSize(width: collectionView.frame.width, height: model.contentHeight)
        }

        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }

    // MARK: - Header / footer

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 58)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 64)
    }
}

// MARK: - P2R

extension FeedController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset

        if scrollOffset.y >= 8 {
            scrollView.endEditing(true)
        }

        if scrollOffset.y <= -150 {
            if !didReachRefreshThreshold {
                Haptic.trigger(with: .medium)
                didReachRefreshThreshold = true
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if didReachRefreshThreshold {
            if shouldDisplaySearch {
                viewModel.reloadSearchData(with: searchDatasource)
            } else {
                viewModel.reloadData(with: datasource)
            }
        }
    }
}

// MARK: - Searchbar

extension FeedController: FeedHeaderDelegate {
    func header(_ header: FeedHeader, wantsSearch text: String?) {
        guard let text = text else {
            shouldDisplaySearch = false
            searchDatasource = []
            postCollection.reloadData()
            viewModel.search(nil)
            return
        }

        viewModel.search(text)
    }
}
