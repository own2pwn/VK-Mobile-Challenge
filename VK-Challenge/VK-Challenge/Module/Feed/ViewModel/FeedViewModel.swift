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

    var onNewItemsLoaded: (([FeedCellViewModel]) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func loadNextPage()
}
