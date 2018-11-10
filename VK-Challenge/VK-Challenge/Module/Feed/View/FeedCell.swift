//
//  FeedCell.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

struct FeedCellViewModel {
    let contentText: NSAttributedString?
}

final class FeedCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet
    private var avatarImageView: UIImageView!

    @IBOutlet
    private var nameLabel: UILabel!

    @IBOutlet
    private var dateLabel: UILabel!

    @IBOutlet
    private var contentLabel: UILabel!

    // MARK: - Init

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
    }

    // MARK: - Setup

    func setup(with viewModel: FeedCellViewModel) {
        contentLabel.attributedText = viewModel.contentText
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }

    func getTextMaxHeight() -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 40
        let maxFrame = CGSize(width: maxWidth, height: 0)

        let maxLines = 8
        let dummy = String(repeating: "\n", count: maxLines)

        let font = UIFont.systemFont(ofSize: 15)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        let result = dummy.boundingRect(with: maxFrame, options: .usesLineFragmentOrigin,
                                        attributes: [.font: font, .paragraphStyle: paragraph],
                                        context: nil)

        return ceil(result.height)
    }

    func getTextHeight(_ text: String) -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - 40
        let maxFrame = CGSize(width: maxWidth, height: 0)

        let font = UIFont.systemFont(ofSize: 15)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        let result = text.boundingRect(with: maxFrame, options: .usesLineFragmentOrigin,
                                       attributes: [.font: font, .paragraphStyle: paragraph],
                                       context: nil)

        return ceil(result.height)
    }

    func testWidth() {
        let bounds = UIScreen.main.bounds
        let frameWidth = bounds.width - 40

        let font = UIFont.systemFont(ofSize: 15)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        let maxSize = CGSize(width: frameWidth, height: 0)
        let size = dummyText.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font, .paragraphStyle: paragraph], context: nil)

        let r = size.height

        // let fontAttributes = [NSAttributedStringKey.font: font]
        // let size = dummyText.size(withAttributes: fontAttributes)
    }

    private func setText() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: dummyText, attributes: [.paragraphStyle: paragraph])

        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15.0, weight: .medium),
            .foregroundColor: UIColor(red: 82.0 / 255.0, green: 139.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0),
        ], range: NSRange(location: 236, length: 19))

        // attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSMakeRange(0, attributedString.length))

        contentLabel.attributedText = attributedString
    }

    private let dummyText = "Одной из ключевых ценностей ВКонтакте является то, что здесь сосредоточено огромное количество уникального контента. Сотни тысяч авторов и пабликов ежедневно создают миллионы материалов, которые невозможно найти нигде, кроме ВКонтакте.\nПоказать полностью…"
}
