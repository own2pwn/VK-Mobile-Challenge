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

    // MARK: - Members

    private var datasource: [FeedCellViewModel] = []

    private let viewModel: FeedViewModel = { Dependency.makeFeedViewModel() }()

    // MARK: Cell Expand

    private var expandedIndexPath: IndexPath?

    private var isCellExpanded = false

    // MARK: P2R

    private let refreshThreshold: CGFloat = 150

    private var didReachRefreshThreshold = false

    private var didReachFooter = false

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.onAvatarLoaded = { [unowned self] avatar in
            self.updateAvatar(with: avatar)
        }
        viewModel.onNewItemsLoaded = { [unowned self] items in
            self.datasource.append(contentsOf: items)
            self.updateFooter()
            self.postCollection.reloadData()
            self.didReachFooter = false
        }
        viewModel.onItemsReloaded = { [unowned self] items in
            self.datasource = items
            self.updateFooter()
            self.postCollection.reloadData()
            self.didReachRefreshThreshold = false
        }
    }

    private func setupCollectionView() {
        postCollection.register(FeedCellWithImage.self)
        postCollection.contentInset.top = 24
        postCollection.contentInset.bottom = 64

        setupKeyboardHandling()
    }

    private func updateAvatar(with image: UIImage?) {
        if let header = postCollection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? FeedHeader {
            header.setAvatar(image)
        }
    }

    private func updateFooter() {
        if let footer = postCollection.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: 0)) as? FeedFooter {
            footer.setLoadedPostCount(datasource.count)
        }
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
        if let header = postCollection.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? FeedHeader {
            header.endEditing(true)
        }
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

extension FeedController: FeedCellExpandDelegate {
    func cell(_ cell: UICollectionViewCell, wantsExpand: Bool) {
        expandedIndexPath = postCollection.indexPath(for: cell)
        isCellExpanded = wantsExpand
        postCollection.collectionViewLayout.invalidateLayout()
    }
}

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = getViewModel(at: indexPath)
        let cell: (AnyFeedCell & UICollectionViewCell)

        if model.postImages.count > 1 {
            cell = collectionView.dequeueReusableCell(ofType: FeedCellWithImage.self, at: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(ofType: FeedCell.self, at: indexPath)
        }

        let shouldExpand = indexPath == expandedIndexPath && isCellExpanded
        cell.setup(with: model, isExpanded: shouldExpand)
        cell.expandDelegate = self

        return cell
    }

    private func getViewModel(at indexPath: IndexPath) -> FeedCellViewModel {
        return datasource[indexPath.row]
    }

    // MARK: - Header

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedHeader", for: indexPath)
        }

        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FeedFooter", for: indexPath)
        }

        return UICollectionReusableView()
    }

    // MARK: - Footer

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter && !datasource.isEmpty {
            if !didReachFooter {
                Haptic.trigger(with: .medium)
                didReachFooter = true
            }

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
        if scrollOffset.y <= -150 {
            if !didReachRefreshThreshold {
                Haptic.trigger(with: .medium)
                didReachRefreshThreshold = true
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if didReachRefreshThreshold {
            viewModel.reloadData(with: datasource)
        }
    }
}
