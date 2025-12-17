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
        let config = URLSessionConfiguration.ephemeral

        // ✅ Avoid huge Cookie headers from Safari/WKWebView storage
        config.httpShouldSetCookies = false
        config.httpCookieStorage = nil
        config.httpCookieAcceptPolicy = .never

        // You can still keep caching if you want, but use a private cache
        config.urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                                  diskCapacity: 0,
                                  diskPath: nil)
        config.requestCachePolicy = .returnCacheDataElseLoad

        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        return URLSession(configuration: config)
    }()

    static func request(url: URL) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
}
