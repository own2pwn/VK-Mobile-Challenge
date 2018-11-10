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

        layoutViewsCount()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutHeader()
        layoutFooter()
    }

    private func layoutHeader() {
        avatarImageView.frame.size = CGSize(width: 36, height: 36)
        avatarImageView.frame.origin = CGPoint(x: 12, y: 12)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2

        let maxLeftX = avatarImageView.frame.maxX

        titleLabel.frame.size = CGSize(width: frame.width - maxLeftX - 10 - 12, height: titleLabel.font.lineHeight)
        titleLabel.frame.origin = avatarImageView.frame.origin
        titleLabel.frame.origin.x = maxLeftX + 10

        dateLabel.frame.size = titleLabel.frame.size
        dateLabel.frame.size.height = dateLabel.font.lineHeight
        dateLabel.frame.origin = titleLabel.frame.origin
        dateLabel.frame.origin.y = titleLabel.frame.maxY + 1

        let maxY = avatarImageView.frame.maxY
        contentLabel.frame.size.width = frame.width - 24
        contentLabel.frame.size.height = frame.height - maxY - 10 - 6 - 44
        contentLabel.frame.origin = CGPoint(x: 12, y: maxY + 10)
    }

    private func layoutFooter() {
        footerView.frame.size.width = frame.width
        footerView.frame.size.height = 44
        footerView.frame.origin.x = 0
        footerView.frame.origin.y = frame.height - 44

        likeImageView.frame.size = CGSize(width: 24, height: 24)
        likeImageView.frame.origin = CGPoint(x: 16, y: 10)

        var maxLeftX = likeImageView.frame.maxX
        let labelsWidth = (frame.width / 4.3) - 40

        likesCountLabel.frame.size.width = labelsWidth
        likesCountLabel.frame.size.height = likesCountLabel.font.lineHeight
        likesCountLabel.center.y = likeImageView.center.y
        likesCountLabel.frame.origin.x = maxLeftX + 4
        maxLeftX = likesCountLabel.frame.maxX

        commentImageView.frame.size = CGSize(width: 24, height: 24)
        commentImageView.center.y = likeImageView.center.y
        commentImageView.frame.origin.x = maxLeftX + 16
        maxLeftX = commentImageView.frame.maxX

        commentsCountLabel.frame.size.width = labelsWidth
        commentsCountLabel.frame.size.height = commentsCountLabel.font.lineHeight
        commentsCountLabel.center.y = likeImageView.center.y
        commentsCountLabel.frame.origin.x = maxLeftX + 4
        maxLeftX = commentsCountLabel.frame.maxX

        repostImageView.frame.size = CGSize(width: 24, height: 24)
        repostImageView.center.y = likeImageView.center.y
        repostImageView.frame.origin.x = maxLeftX + 16
        maxLeftX = repostImageView.frame.maxX

        repostsCountLabel.frame.size.width = labelsWidth
        repostsCountLabel.frame.size.height = repostsCountLabel.font.lineHeight
        repostsCountLabel.center.y = likeImageView.center.y
        repostsCountLabel.frame.origin.x = maxLeftX + 4
        maxLeftX = repostsCountLabel.frame.maxX

        layoutViewsCount()
    }

    private func layoutViewsCount() {
        viewsCountLabel.sizeToFit()
        viewsCountLabel.center.y = likeImageView.center.y
        viewsCountLabel.frame.origin.x = frame.width - 16 - viewsCountLabel.frame.width

        viewsCountImageView.frame.size = CGSize(width: 20, height: 20)
        viewsCountImageView.center.y = likeImageView.center.y
        viewsCountImageView.frame.origin.x = viewsCountLabel.frame.minX - 2 - 20
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
