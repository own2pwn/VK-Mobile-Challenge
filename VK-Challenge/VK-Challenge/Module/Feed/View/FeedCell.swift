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

        setupCell()

        // ==

//        clipsToBounds = false
//
//        let shadowLayer = CALayer()
//        shadowLayer.shadowColor = UIColor.red.cgColor
//        shadowLayer.shadowRadius = 9
//        shadowLayer.shadowOffset = CGSize(width: 0, height: 24)
//        shadowLayer.shadowOpacity = 1
//        shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
//        layer.insertSublayer(shadowLayer, at: 1)
    }

    private func setupCell() {
        backgroundColor = .clear
        layer.shadowOffset = CGSize(width: 0, height: 24)
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.07
        layer.shadowColor = UIColor.rgb(99 103, 111).cgColor

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10

//        clipsToBounds = false
//        layer.cornerRadius = 10
//        shadowView.layer.cornerRadius = 10

//        backgroundColor = .clear
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 10
//        shadowView.layer.cornerRadius = 10
//
//        updateShadow()

//        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
//        let shadowLayer = CALayer()
//        shadowLayer.shadowPath = shadowPath.cgPath
//        shadowLayer.shadowColor = UIColor(red: 0.39, green: 0.4, blue: 0.44, alpha: 0.07).cgColor
//        shadowLayer.shadowOpacity = 1
//        shadowLayer.shadowRadius = 18
//        shadowLayer.shadowOffset = CGSize(width: 0, height: 24)
//        shadowLayer.bounds = bounds
//        shadowLayer.position = center
//        contentView.layer.addSublayer(shadowLayer)
        // setText()
    }

    func updateShadow() {
//        shadowView.layer.shadowColor = UIColor.red.cgColor
//        shadowView.layer.shadowRadius = 9
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 24)
//        shadowView.layer.shadowOpacity = 1
//        shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2

        // ==
    }

    func testShadow() {
        let shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 10)
        let shadowLayer = contentView.layer
        shadowLayer.shadowPath = shadowPath.cgPath
        shadowLayer.shadowColor = UIColor.red.cgColor
        // shadowLayer.shadowColor = UIColor(red: 0.39, green: 0.4, blue: 0.44, alpha: 1).cgColor
        shadowLayer.shadowOpacity = 1 // 0.07
        shadowLayer.shadowRadius = 9
        shadowLayer.shadowOffset = CGSize(width: 0, height: 24)
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
