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

    var onItemsReloaded: (([FeedCellViewModel]) -> Void)? { get set }

    var onNewItemsLoaded: (([FeedCellViewModel]) -> Void)? { get set }

    var onSearchResultLoaded: (([FeedCellViewModel]) -> Void)? { get set }

    var onNewSearchItemsLoaded: (([FeedCellViewModel]) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func reloadData(with currentLoadedData: [FeedCellViewModel])
    func reloadSearchData(with currentLoadedData: [FeedCellViewModel])

    func loadNextPage()
    func loadNextSearchPage()
    
    func search(_ searchText: String?)
}
