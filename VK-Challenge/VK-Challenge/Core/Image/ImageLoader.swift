//
//  ImageLoader.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

typealias ImageCompletion = (UIImage) -> Void

final class ImageLoader {
    // MARK: - Members

    private var cached: [String: Data] = [:]

    private let maxCacheSize: Int = {
        let pxInOneMB = 1024 * 1024 / 4

        return 7 * pxInOneMB
    }()

    private lazy var session: URLSession = {
        var config = URLSession.shared.configuration
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        let custom = URLSession(configuration: config)

        return custom
    }()

    // MARK: - Interface

    @discardableResult
    func load(from url: String, completion: @escaping ImageCompletion) -> URLSessionDataTask? {
        guard let endpoint = URL(string: url) else { return nil }

        if let data = cached[url], let image = UIImage(data: data) {
            DispatchQueue.main.async { completion(image) }
            return nil
        }

        let task = session.dataTask(with: endpoint) { data, _, _ in
            guard
                let data = data,
                let image = UIImage(data: data) else { return }

            DispatchQueue.main.async { completion(image) }
            self.cache(url, data)
        }
        task.resume()

        return task
    }

    // MARK: - Helpers

    private func cache(_ key: String, _ data: Data) {
        let freeSpace = maxCacheSize - currentCacheSize
        let upperBound = maxCacheSize / 4

        if freeSpace >= upperBound {
            cacheNewItem(key, data)
        } else {
            removeHeaviest()
            cacheNewItem(key, data)
        }
    }

    private func removeHeaviest() {
        let topmost = cached.sorted(by: { $0.1.count > $1.1.count })[0]
        cached[topmost.key] = nil
    }

    private func cacheNewItem(_ key: String, _ value: Data) {
        cached[key] = value
    }

    private var currentCacheSize: Int {
        return cached.values.map { $0.count }.reduce(0, +)
    }
}
