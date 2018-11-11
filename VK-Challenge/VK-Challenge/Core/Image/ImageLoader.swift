//
//  ImageLoader.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

typealias ImageCompletion = (UIImage) -> Void

private struct CacheEntry {
    let key: String
    let value: Data
}

extension CacheEntry: Comparable {
    static func < (lhs: CacheEntry, rhs: CacheEntry) -> Bool {
        return lhs.value.count < rhs.value.count
    }
}

final class ImageLoader {
    // MARK: - Members

    private var cached: [CacheEntry] = []

    private let maxCacheSize: Int = {
        let pxInOneMB = 1024 * 1024 / 4

        return 12 * pxInOneMB
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

        if let data = getData(for: url), let image = UIImage(data: data) {
            DispatchQueue.main.async { completion(image) }
            return nil
        }

        let task = session.dataTask(with: endpoint) { data, _, _ in
            guard
                let data = data,
                let image = UIImage(data: data) else { return }

            self.cache(url, data)
            DispatchQueue.main.async { completion(image) }
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

    private func getData(for key: String) -> Data? {
        let entry = cached.first(where: { $0.key == key })

        return entry?.value
    }

    private func removeHeaviest() {
        cached.sort(by: >)
        cached.removeFirst(2)

        print("clear cache")
    }

    private func cacheNewItem(_ key: String, _ value: Data) {
        let entry = CacheEntry(key: key, value: value)
        cached.append(entry)
    }

    private var currentCacheSize: Int {
        return cached.map { $0.value.count }.reduce(0, +)
    }
}
