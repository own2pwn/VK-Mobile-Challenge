//
//  FeedCell.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol FeedCellExpandDelegate: class {
    func cell(_ cell: FeedCell, wantsExpand: Bool)
}

final class FeedCell: UICollectionViewCell {
    // MARK: - Interface

    weak var expandDelegate: FeedCellExpandDelegate?

    private var isExpanded = false

    // MARK: - Outlets

    @IBOutlet
    private var avatarImageView: UIImageView!

    @IBOutlet
    private var titleLabel: UILabel!

    @IBOutlet
    private var dateLabel: UILabel!

    @IBOutlet
    private var contentLabel: UILabel!

    @IBOutlet
    private var likesCountLabel: UILabel!

    @IBOutlet
    private var commentsCountLabel: UILabel!

    @IBOutlet
    private var repostsCountLabel: UILabel!

    @IBOutlet
    private var viewsCountImageView: UIImageView!

    @IBOutlet
    private var viewsCountLabel: UILabel!

    // MARK: - Private

    private lazy var pan
        = UITapGestureRecognizer(target: self, action: #selector(toggleTextCollapse))

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

    func setup(with viewModel: FeedCellViewModel, isExpanded: Bool = false) {
        self.viewModel = viewModel
        self.isExpanded = isExpanded

        titleLabel.text = viewModel.titleText
        dateLabel.text = viewModel.dateText
        likesCountLabel.text = viewModel.likesCount.stringValue
        commentsCountLabel.text = viewModel.commentsCount.stringValue
        repostsCountLabel.text = viewModel.repostCount.stringValue
        viewsCountImageView.isHidden = viewModel.viewsCount == nil
        viewsCountLabel.text = viewModel.viewsCount?.stringValue

        if isExpanded {
            contentLabel.attributedText = viewModel.contentText
        } else {
            contentLabel.attributedText = viewModel.shortText ?? viewModel.contentText
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
        isExpanded.toggle()

        expandDelegate?.cell(self, wantsExpand: isExpanded)

        if isExpanded {
            contentLabel.attributedText = viewModel?.contentText
        } else {
            contentLabel.attributedText = viewModel?.shortText
        }
    }
}

private extension Int {
    var stringValue: String? {
        return self > 0 ? "\(self)" : nil
    }
}
