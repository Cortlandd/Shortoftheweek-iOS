//
//  FeedClient.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Dependencies
import Foundation

struct FeedClient {
    enum Endpoint: Equatable, Hashable {
        case mixed
        case news
        case search(query: String)
    }

    var loadPage: @Sendable (_ endpoint: Endpoint, _ page: Int, _ limit: Int) async throws -> [Film]
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

    func get(endpoint: FeedClient.Endpoint, page: Int, limit: Int) -> [Film]? {
        let key = cacheKey(endpoint: endpoint, page: page, limit: limit)
        guard let entry = entries[key] else { return nil }
        if Date().timeIntervalSince(entry.insertedAt) > ttl {
            entries[key] = nil
            return nil
        }
        return entry.films
    }

    func set(_ films: [Film], endpoint: FeedClient.Endpoint, page: Int, limit: Int) {
        let key = cacheKey(endpoint: endpoint, page: page, limit: limit)
        entries[key] = Entry(films: films, insertedAt: Date())
    }

    private func cacheKey(endpoint: FeedClient.Endpoint, page: Int, limit: Int) -> String {
        switch endpoint {
        case .mixed:
            return "mixed-p:\(page)-l:\(limit)"
        case .news:
            return "news-p:\(page)-l:\(limit)"
        case .search(let q):
            // Normalize query so "No Vacancy" and "no vacancy" cache together.
            let normalized = q
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            return "search-q:\(normalized)-p:\(page)-l:\(limit)"
        }
    }
}

extension FeedClient: DependencyKey {

    static let liveValue: FeedClient = .init { endpoint, page, limit in
        let cache = FeedPageCacheHolder.shared

        if let cached = await cache.cache.get(endpoint: endpoint, page: page, limit: limit) {
            return cached
        }

        let url = try buildURL(endpoint: endpoint, page: page, limit: limit)
        let request = NetworkSession.request(url: url)
        let (data, _) = try await NetworkSession.shared.data(for: request)

        do {
            let response = try JSONDecoder().decode(FeedResponse.self, from: data)
            let films = response.data.map(Film.init(feedItem:))
            await cache.cache.set(films, endpoint: endpoint, page: page, limit: limit)
            return films
        } catch {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ Feed decode failed: \(DecodeDebug.describe(error))")
            print("↪️ Raw body (first 2000 chars): \(body.prefix(2000))")
            throw error
        }
    }

    static let testValue: FeedClient = .init(
        loadPage: { _, _, _ in [] }
    )

    // MARK: - URL builder

    private static func buildURL(endpoint: FeedClient.Endpoint, page: Int, limit: Int) throws -> URL {
        let base: String
        var queryItems: [URLQueryItem] = [
            .init(name: "limit", value: "\(limit)"),
            .init(name: "page", value: "\(page)")
        ]

        switch endpoint {
        case .mixed:
            base = "https://www.shortoftheweek.com/api/v1/mixed"

        case .news:
            base = "https://www.shortoftheweek.com/api/v1/news/"

        case .search(let query):
            base = "https://www.shortoftheweek.com/api/v1/search"
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            queryItems.insert(.init(name: "q", value: trimmed), at: 0)
        }

        guard var components = URLComponents(string: base) else {
            throw URLError(.badURL)
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
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
