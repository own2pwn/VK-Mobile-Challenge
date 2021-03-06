//
//  FeedCellCarouselCell.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

final class FeedCellCarouselCell: UICollectionViewCell {
    // MARK: - Views

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    // MARK: - Interface

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    // MARK: - Setup

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = contentView.frame
    }
}
