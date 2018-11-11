//
//  FeedHeader.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol FeedHeaderDelegate: class {
    func header(_ header: FeedHeader, wantsSearch text: String?)
}

final class FeedHeader: UICollectionReusableView {
    // MARK: - Interface

    weak var delegate: FeedHeaderDelegate?

    // MARK: - Outlets

    @IBOutlet
    private var searchBar: UISearchBar!

    @IBOutlet
    private var avatarImageView: UIImageView!

    // MARK: - Interface

    func setAvatar(_ image: UIImage?) {
        avatarImageView.image = image
    }

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()

        searchBar.delegate = self
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
}

extension FeedHeader: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }

        delegate?.header(self, wantsSearch: searchText)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            delegate?.header(self, wantsSearch: nil)
        }
    }
}
