//
//  FeedHeader.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

final class FeedHeader: UICollectionReusableView {
    // MARK: - Outlets

    @IBOutlet
    private var avatarImageView: UIImageView!

    // MARK: - Interface

    func setAvatar(_ image: UIImage?) {
        avatarImageView.image = image
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
}

final class FeedFooter: UICollectionReusableView {
    // MARK: - Outlets

    @IBOutlet
    private var loadedPostCountLabel: UILabel!

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()

        loadedPostCountLabel.text = nil
    }

    // MARK: - Interface

    func setLoadedPostCount(_ count: Int) {
        loadedPostCountLabel.text = count > 0 ? "\(count) записей" : nil
    }
}
