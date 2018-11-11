//
//  FeedService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 10/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

typealias VKFeedBlock = (VKFeedResponseModel) -> Void

typealias VKSearchBlock = (VKSearchResponseModel) -> Void

final class FeedService {
    // MARK: - Members

    private let api: VKAPIClient

    // MARK: - Interface

    func getNews(result: @escaping VKFeedBlock) {
        let filters = makeQueryItem(field: .filters, params: [.post])
        let fields = makeQueryItem(field: .fields, params: [.photo100])

        let query = [filters, fields]

        api.get(method: .feedGet, params: query, completion: result)
    }

    func getNextPage(token: String, result: @escaping VKFeedBlock) {
        let filters = makeQueryItem(field: .filters, params: [.post])
        let fields = makeQueryItem(field: .fields, params: [.photo100])
        let nextPage = QueryItem(field: VKAPIFeedField.startFrom, value: token)

        let query = [filters, fields, nextPage]

        api.get(method: .feedGet, params: query, completion: result)
    }

    func search(_ searchText: String, result: @escaping VKSearchBlock) {
        let query = QueryItem(field: VKAPIFeedField.query, value: searchText)
        let extended = QueryItem(field: VKAPIFeedField.extended, value: "1")
        let fields = makeQueryItem(field: .fields, params: [.photo100])

        api.get(method: .feedSearch, params: [query, extended, fields], completion: result)
    }

    func getNextSearchPage(token: String, searchText: String, result: @escaping VKSearchBlock) {
        let query = QueryItem(field: VKAPIFeedField.query, value: searchText)
        let extended = QueryItem(field: VKAPIFeedField.extended, value: "1")
        let fields = makeQueryItem(field: .fields, params: [.photo100])
        let nextPage = QueryItem(field: VKAPIFeedField.startFrom, value: token)

        api.get(method: .feedSearch, params: [query, extended, fields, nextPage], completion: result)
    }

    // MARK: - Helpers

    private func makeQueryItem(field: VKAPIFeedField, params: [VKAPIFieldValue]) -> QueryItem {
        return QueryItem(field: field, values: params)
    }

    // MARK: - Init

    init(api: VKAPIClient) {
        self.api = api
    }
}
