//
//  FeedViewModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol FeedViewModelOutput: class {
    var onAvatarLoaded: ((UIImage?) -> Void)? { get set }

    var onItemsReloaded: (([FeedCellViewModel], Bool) -> Void)? { get set }

    var onNewItemsLoaded: (([FeedCellViewModel], Bool) -> Void)? { get set }

    var onSearchResultLoaded: (([FeedCellViewModel], Bool) -> Void)? { get set }

    var onSearchResultReloaded: (([FeedCellViewModel], Bool) -> Void)? { get set }

    var onNewSearchItemsLoaded: (([FeedCellViewModel], Bool) -> Void)? { get set }

    var hasMoreDataChanged: ((Bool) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func reloadData(with currentLoadedData: [FeedCellViewModel])
    func reloadSearchData(with currentLoadedData: [FeedCellViewModel])

    func loadNextPage()
    func loadNextSearchPage()

    func search(_ searchText: String?)
}
