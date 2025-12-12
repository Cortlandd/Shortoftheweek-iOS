//
//  NetworkSession.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import Foundation

/// Centralized URLSession with caching-friendly defaults.
///
/// - Uses `URLCache.shared` (configured in `ShortoftheWeekApp`).
/// - Defaults to `returnCacheDataElseLoad` so rapid scroll/navigation doesn't
///   spam the API for identical resources.
enum NetworkSession {
    static let shared: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = .shared
        config.requestCachePolicy = .returnCacheDataElseLoad
        // Avoid very aggressive network behavior when the user scrolls quickly.
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    static func request(
        url: URL,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        return request
    }
}
