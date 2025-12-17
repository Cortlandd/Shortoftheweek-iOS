//
//  FeedModels.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Foundation

/// Top-level response from /api/v1/mixed
public struct FeedResponse: Decodable, Sendable {
    let count: Int
    let limit: Int
    let page: Int
    let total: Int
    let pageMax: Int
    let links: FeedPageLinks
    let data: [FeedItem]

    enum CodingKeys: String, CodingKey {
        case count, limit, page, total, data
        case pageMax = "page_max"
        case links = "_links"
    }
}

public struct FeedPageLinks: Decodable, Sendable {
    let first: URL?
    let last: URL?
    let next: URL?
    let previous: URL?
}

/// Category / country / style / topic, etc.
public struct FeedTerm: Equatable, Decodable, Sendable {
    let id: Int?
    let color: String?
    let displayName: String?
    let slug: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case color
        case displayName = "display_name"
        case slug
    }
}

/// The nested `categories` / `tags` object with paging + data[].
public struct FeedTermCollection: Decodable, Sendable {
    let count: Int
    let limit: Int
    let page: Int
    let total: Int
    let pageMax: Int
    let links: FeedPageLinks?
    let data: [FeedTerm]

    enum CodingKeys: String, CodingKey {
        case count, limit, page, total, data
        case pageMax = "page_max"
        case links = "_links"
    }
}

public struct FeedAuthor: Equatable, Decodable, Sendable {
    let displayName: String
    let firstName: String?
    let lastName: String?
    let id: String
    let company: String?
    let occupation: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case id = "ID"
        case company, occupation, email
    }
}

/// Built to handle bad URLs and label Arrays
public struct FeedExternalLink: Decodable, Sendable, Equatable {
    public let url: URL?
    public let label: StringOrStringArray?

    enum CodingKeys: String, CodingKey {
        case url, label
    }

    public var bestLabel: String? {
        label?.first ?? label?.joined
    }
}

public struct FeedItem: Decodable, Sendable {
    let id: Int
    let postAuthor: String
    let postContentHTML: String
    let postDateString: String
    let postTitle: String
    let postName: String
    let backgroundImage: String?
    let categories: FeedTermCollection?
    let author: FeedAuthor?
    let country: FeedTerm?
    let filmmaker: String?
    let labels: StringOrStringArray?
    let links: [FeedExternalLink]?
    let durationString: String?
    let genre: FeedTerm?
    let playLink: String?
    let playLinkTarget: String?
    let postExcerpt: String?
    let production: String?
    let style: FeedTerm?
    let subscriptions: BoolOrArray?
    let tags: FeedTermCollection?
    let textColor: String?
    let twitterText: String?
    let thumbnail: String?
    let type: String // "video", "article", etc.
    let topic: FeedTerm?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case postAuthor = "post_author"
        case postContentHTML = "post_content"
        case postDateString = "post_date"
        case postTitle = "post_title"
        case postName = "post_name"
        case backgroundImage = "background_image"
        case categories
        case author
        case country
        case filmmaker
        case labels
        case links
        case durationString = "duration"
        case genre
        case playLink = "play_link"
        case playLinkTarget = "play_link_target"
        case postExcerpt = "post_excerpt"
        case production
        case style
        case subscriptions
        case tags
        case textColor = "text_color"
        case twitterText = "twitter_text"
        case thumbnail
        case type
        case topic
    }
}

// Because strangely it can be an array or bool. weird
public enum BoolOrArray: Decodable, Equatable, Sendable {
    case bool(Bool)
    case arrayCount(Int)

    public var asBool: Bool {
        switch self {
        case let .bool(b): return b
        case let .arrayCount(count): return count > 0
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) {
            self = .bool(b)
        } else if let arr = try? c.decode([AnyDecodable].self) {
            self = .arrayCount(arr.count)
        } else {
            self = .bool(false)
        }
    }
}

/// AnyDecodable lets us decode “whatever” without caring.
public struct AnyDecodable: Decodable, Equatable, Sendable {
    public init(from decoder: Decoder) throws { }
}

/// Decodes either:
/// - "News"
/// - ["News", "Interviews"]
/// - null / missing
public struct StringOrStringArray: Decodable, Equatable, Sendable {
    public let values: [String]

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if c.decodeNil() {
            self.values = []
        } else if let s = try? c.decode(String.self) {
            self.values = [s]
        } else if let arr = try? c.decode([String].self) {
            self.values = arr
        } else {
            self.values = []
        }
    }

    public var joined: String { values.joined(separator: " / ") }
    public var first: String? { values.first }
}

public struct StringOrInt: Decodable, Equatable, Sendable {
    public let value: String

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) { value = s; return }
        if let i = try? c.decode(Int.self) { value = String(i); return }
        value = ""
    }
}
