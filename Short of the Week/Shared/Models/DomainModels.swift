//
//  DomainModels.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Foundation

public struct Film: Equatable, Identifiable, Sendable {
    public enum Kind: String, Equatable, Sendable {
        case video
        case article
        case news
        case unknown
    }

    public var id: Int
    public var kind: Kind

    public var title: String
    public var slug: String
    public var synopsis: String?
    public var postDate: Date?

    public var backgroundImageURL: URL?
    public var thumbnailURL: URL?

    public var filmmaker: String?
    public var production: String?

    public var durationMinutes: Int?
    public var country: FeedTerm?
    public var genre: FeedTerm?
    public var style: FeedTerm?
    public var topic: FeedTerm?

    public var author: FeedAuthor?
    public var categories: [FeedTerm]

    public var playURL: URL?
    public var textColor: String?

    /// Full review/article HTML from `post_content`.
    public var articleHTML: String
}


// MARK: - Mapping from FeedItem

extension Film {
    public init(feedItem: FeedItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        id = feedItem.id
        let t = feedItem.type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if t == "news" {
            self.kind = .news
        } else if t == "video" || self.playURL != nil {
            self.kind = .video
        } else if t == "article" {
            self.kind = .article
        } else {
            self.kind = .unknown
        }
        title = feedItem.postTitle.htmlDecoded
        slug = feedItem.postName
        synopsis = feedItem.postExcerpt?.htmlDecoded
        postDate = formatter.date(from: feedItem.postDateString)

        backgroundImageURL = feedItem.backgroundImage?.canonicalSOTWURL()
        thumbnailURL = feedItem.thumbnail?.canonicalSOTWURL()

        filmmaker = feedItem.filmmaker?.htmlDecoded
        production = feedItem.production?.htmlDecoded

        durationMinutes = Int(feedItem.durationString ?? "")
        country = feedItem.country
        genre = feedItem.genre
        style = feedItem.style
        topic = feedItem.topic

        author = feedItem.author
        categories = feedItem.categories?.data ?? []

        playURL = feedItem.playLink.flatMap(URL.init(string:))
        textColor = feedItem.textColor

        articleHTML = feedItem.postContentHTML
        playURL = feedItem.playLink?.canonicalSOTWURL()
        textColor = feedItem.textColor
    }
}

extension Film {
    var isNews: Bool { kind.rawValue.lowercased() == "news" }

    var headerCategoryLabel: String? {
        categories.first?.displayName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
}

extension String {
    func canonicalSOTWURL() -> URL? {
        if hasPrefix("//") {
            return URL(string: "https:\(self)")
        } else {
            return URL(string: self)
        }
    }
}
