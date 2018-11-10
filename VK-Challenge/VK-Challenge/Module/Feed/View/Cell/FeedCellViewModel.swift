//
//  FeedCellViewModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

struct FeedCellViewModel {
    let titleText: String
    let dateText: String
    let contentText: NSAttributedString
    let shortText: NSAttributedString?
    let avatarURL: String
    let imageLoader: ImageLoader

    let likesCount: Int
    let commentsCount: Int
    let repostCount: Int
    let viewsCount: Int?

    let contentHeight: CGFloat
    let shortContentHeight: CGFloat?
}
