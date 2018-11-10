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

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        postCollection.contentInset.top = 36
    }

    // MARK: - Members

    private var expandedIndexPath: IndexPath?

    private var isCellExpanded = false

    private var datasource: [FeedCellViewModel] = []

    private let viewModel: FeedViewModel = { Dependency.makeFeedViewModel() }()

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.onAvatarLoaded = { [unowned self] avatar in
            self.updateAvatar(with: avatar)
        }
        viewModel.onNewItemsLoaded = { [unowned self] items in
            self.datasource.append(contentsOf: items)
            self.postCollection.reloadData()
        }
    }

    private func updateAvatar(with image: UIImage?) {
        if let header = postCollection.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? FeedHeader {
            header.setAvatar(image)
        }
    }
}

// ===

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeedCell = collectionView.dequeueReusableCell(at: indexPath)
        let model = getViewModel(at: indexPath)
        let shouldExpand = indexPath == expandedIndexPath && isCellExpanded

        cell.setup(with: model, isExpanded: shouldExpand)
        cell.expandDelegate = self

        return cell
    }

    private func getViewModel(at indexPath: IndexPath) -> FeedCellViewModel {
        return datasource[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FeedHeader", for: indexPath)

        return view
    }
}

extension FeedController: FeedCellExpandDelegate {
    func cell(_ cell: FeedCell, wantsExpand: Bool) {
        expandedIndexPath = postCollection.indexPath(for: cell)
        isCellExpanded = wantsExpand
        postCollection.collectionViewLayout.invalidateLayout()
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        guard row < datasource.count else {
            return CGSize(width: collectionView.frame.width, height: 256)
        }
        let model = getViewModel(at: indexPath)
        let cellHeight = model.shortContentHeight ?? model.contentHeight

        if indexPath == expandedIndexPath {
            if isCellExpanded {
                return CGSize(width: collectionView.frame.width, height: model.contentHeight)
            }
        }

        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 58)
    }
}
