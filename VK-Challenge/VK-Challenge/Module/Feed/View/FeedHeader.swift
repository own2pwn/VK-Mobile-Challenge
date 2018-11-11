//
//  FeedHeader.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol FeedHeaderDelegate: class {
    func header(_ header: FeedHeader, wantsSearch text: String)
}

final class FeedHeader: UICollectionReusableView {
    // MARK: - Interface

    weak var delegate: FeedHeaderDelegate?

    // MARK: - Members

    private var currentTimer: DispatchSourceTimer?

    private var currentText: String?

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

    // MARK: - Methods

    private func makeBouncer() {
        let queue = DispatchQueue(label: "own2pwn.svc.tmr", qos: .utility, attributes: .concurrent)
        let newTimer = DispatchSource.makeTimerSource(queue: queue)

        newTimer.schedule(deadline: .now() + 0.8, repeating: .seconds(1), leeway: .milliseconds(500))
        newTimer.setEventHandler { [weak self] in
            self?.onBounce()
        }
        newTimer.resume()

        currentTimer = newTimer
    }

    private func onBounce() {
        guard let searchText = currentText else { return }

        delegate?.header(self, wantsSearch: searchText)

        if searchText.isEmpty {
            currentText = nil
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
}

extension FeedHeader: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if currentTimer == nil {
            makeBouncer()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        onBounce()

        currentTimer?.cancel()
        currentTimer = nil
        currentText = nil
    }
}
