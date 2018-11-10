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

        layoutHeader()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }

    private func layoutHeader() {
        avatarImageView.frame.size = CGSize(width: 36, height: 36)
        avatarImageView.frame.origin = CGPoint(x: 12, y: 12)

        var maxLeftX = avatarImageView.frame.maxX

        titleLabel.frame.size = CGSize(width: frame.width - maxLeftX - 10 - 12, height: titleLabel.font.lineHeight)
        titleLabel.frame.origin = avatarImageView.frame.origin
        titleLabel.frame.origin.x = maxLeftX + 10
        titleLabel.drawText(in: titleLabel.frame)

        dateLabel.frame.size = titleLabel.frame.size
        dateLabel.frame.size.height = dateLabel.font.lineHeight
        dateLabel.frame.origin = titleLabel.frame.origin
        dateLabel.frame.origin.y = titleLabel.frame.maxY + 1
        dateLabel.drawText(in: dateLabel.frame)

        let contentRect = CGSize(width: frame.width - 24, height: 0)
        let textRect = contentLabel.attributedText?.boundingRect(with: contentRect, options: .usesLineFragmentOrigin, context: nil)

        contentLabel.frame.size = contentRect
        contentLabel.frame.size.height = textRect?.height ?? 0
        contentLabel.frame.origin = CGPoint(x: 12, y: avatarImageView.frame.maxY + 10)
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
