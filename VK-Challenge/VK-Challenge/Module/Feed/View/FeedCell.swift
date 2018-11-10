//
//  FeedCell.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09/11/2018.
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
}

final class FeedCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet
    private var avatarImageView: UIImageView!

    @IBOutlet
    private var titleLabel: UILabel!

    @IBOutlet
    private var dateLabel: UILabel!

    @IBOutlet
    private var contentLabel: UILabel!

    // MARK: - Private

    private lazy var pan
        = UITapGestureRecognizer(target: self, action: #selector(toggleTextCollapse))

    private var isExpanded = false

    private var imageLoadingTask: URLSessionDataTask?

    private var viewModel: FeedCellViewModel?

    // MARK: - Methods

    override func prepareForReuse() {
        super.prepareForReuse()

        imageLoadingTask?.cancel()
        imageLoadingTask = nil
        isExpanded = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCell()
    }

    private func setupCell() {
        clipsToBounds = false
        backgroundColor = .clear
        layer.shadowOffset = CGSize(width: 0, height: 24)
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.07
        layer.shadowColor = UIColor.rgb(99, 103, 111).cgColor

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        contentLabel.isUserInteractionEnabled = true
        contentLabel.addGestureRecognizer(pan)
    }

    // MARK: - Setup

    func setup(with viewModel: FeedCellViewModel) {
        self.viewModel = viewModel

        titleLabel.text = viewModel.titleText
        dateLabel.text = viewModel.dateText

        if let shortText = viewModel.shortText {
            contentLabel.attributedText = shortText
        } else {
            contentLabel.attributedText = viewModel.contentText
        }

        imageLoadingTask = viewModel.imageLoader.load(from: viewModel.avatarURL) { [weak self] image in
            self?.avatarImageView.image = image
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }

    // MARK: - Actions

    @objc
    private func toggleTextCollapse() {
        guard viewModel?.shortText != nil else { return }

        defer { isExpanded.toggle() }

        if isExpanded {
            contentLabel.attributedText = viewModel?.shortText
        } else {
            contentLabel.attributedText = viewModel?.contentText
        }
    }
}
