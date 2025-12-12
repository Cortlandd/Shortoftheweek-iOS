//
//  FeedClient.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Dependencies
import Foundation

struct FeedClient {
    var loadPage: @Sendable (_ page: Int, _ limit: Int) async throws -> [Film]
}

/// Very small in-memory cache so we don't refetch the same page repeatedly
/// during rapid scrolling / navigation.
private actor FeedPageCache {
    struct Entry {
        let films: [Film]
        let insertedAt: Date
    }

    private var entries: [String: Entry] = [:]
    private let ttl: TimeInterval = 10 * 60 // 10 minutes

    func get(page: Int, limit: Int) -> [Film]? {
        let key = "p:\(page)-l:\(limit)"
        guard let entry = entries[key] else { return nil }
        if Date().timeIntervalSince(entry.insertedAt) > ttl {
            entries[key] = nil
            return nil
        }
        return entry.films
    }

    func set(_ films: [Film], page: Int, limit: Int) {
        let key = "p:\(page)-l:\(limit)"
        entries[key] = Entry(films: films, insertedAt: Date())
    }
}

extension FeedClient: DependencyKey {
    static let liveValue: FeedClient = .init { page, limit in
        let cache = FeedPageCacheHolder.shared
        if let cached = await cache.cache.get(page: page, limit: limit) {
            return cached
        }

        var components = URLComponents(string: "https://www.shortoftheweek.com/api/v1/mixed")!
        components.queryItems = [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "page", value: "\(page)")
        ]

//        let (data, _) = try await URLSession.shared.data(from: components.url!)
//        let decoder = JSONDecoder()
//        let response = try decoder.decode(FeedResponse.self, from: data)
//        return response.data.map(Film.init(feedItem:))

        let url = components.url!
        let request = NetworkSession.request(url: url)
        let (data, _) = try await NetworkSession.shared.data(for: request)

        do {
            let response = try JSONDecoder().decode(FeedResponse.self, from: data)
            let films = response.data.map(Film.init(feedItem:))
            await cache.cache.set(films, page: page, limit: limit)
            return films
        } catch {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ Feed decode failed: \(DecodeDebug.describe(error))")
            print("↪️ Raw body (first 2000 chars): \(body.prefix(2000))")
            throw error
        }
    }

    static let testValue: FeedClient = .init(
        loadPage: { _, _ in [] }
    )
}

/// Single shared cache instance used by the live dependency.
private final class FeedPageCacheHolder {
    static let shared = FeedPageCacheHolder()
    let cache = FeedPageCache()
    private init() {}
}

extension DependencyValues {
    var feedClient: FeedClient {
        get { self[FeedClient.self] }
        set { self[FeedClient.self] = newValue }
    }
}
