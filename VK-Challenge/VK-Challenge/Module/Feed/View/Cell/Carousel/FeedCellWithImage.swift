//
//  FeedCellWithImage.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

final class FeedCellWithImage: UICollectionViewCell {
    // MARK: - Outlets

    // ==== Header

    @IBOutlet
    private var avatarImageView: UIImageView!

    @IBOutlet
    private var titleLabel: UILabel!

    @IBOutlet
    private var dateLabel: UILabel!

    // ==== Content

    @IBOutlet
    private var contentLabel: UILabel!

    @IBOutlet
    private var postImageCollection: UICollectionView!

    // ==== Footer

    @IBOutlet
    private var footerView: UIView!

    @IBOutlet
    private var likeImageView: UIImageView!

    @IBOutlet
    private var likesCountLabel: UILabel!

    @IBOutlet
    private var commentImageView: UIImageView!

    @IBOutlet
    private var commentsCountLabel: UILabel!

    @IBOutlet
    private var repostImageView: UIImageView!

    @IBOutlet
    private var repostsCountLabel: UILabel!

    @IBOutlet
    private var viewsCountImageView: UIImageView!

    @IBOutlet
    private var viewsCountLabel: UILabel!

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
