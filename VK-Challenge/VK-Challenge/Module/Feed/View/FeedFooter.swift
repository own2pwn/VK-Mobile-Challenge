//
//  FeedFooter.swift
//  VK-Challenge
//
//  Created by Evgeniy on 11/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

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
