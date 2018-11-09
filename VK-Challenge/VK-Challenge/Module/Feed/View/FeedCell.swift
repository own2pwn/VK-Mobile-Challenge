//
//  FeedCell.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

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

        internalInit()
    }

    private func internalInit() {
        layer.cornerRadius = 8

        setText()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }

    func testWidth() {
        let frameWidth = contentView.frame.width
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
