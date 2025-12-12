//
//  BookmarksClient.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Dependencies
import Foundation
import CoreData
import ComposableArchitecture

//struct BookmarksClient {
//    /// Load all bookmarks, newest first.
//    public var load: @Sendable () async throws -> [Bookmark]
//
//    /// Save a bookmark snapshot for a Film (idempotent on film.id).
//    public var add: @Sendable (_ film: Film) async throws -> Void
//
//    /// Delete bookmark by film id.
//    public var remove: @Sendable (_ filmID: Int) async throws -> Void
//    
//    public init(
//        load: @escaping @Sendable () async throws -> [Bookmark],
//        add: @escaping @Sendable (_ film: Film) async throws -> Void,
//        remove: @escaping @Sendable (_ filmID: Int) async throws -> Void
//    ) {
//        self.load = load
//        self.add = add
//        self.remove = remove
//    }
//}
//
//extension BookmarksClient: DependencyKey {
//    public static let liveValue: BookmarksClient = .init(
//        load: {
//            // TODO: Core Data fetch
//            // Fetch BookmarkEntity, decode payloadJSON to Film, map to Bookmark
//            return []
//        },
//        add: { film in
//            // TODO:
//            // - Encode `film` or original `FeedItem` to Data with JSONEncoder
//            // - Upsert BookmarkEntity(id: film.id, payloadJSON: data, createdAt: now)
//        },
//        remove: { filmID in
//            // TODO:
//            // - Find BookmarkEntity with id == filmID and delete it
//        }
//    )
//
//    public static let testValue: BookmarksClient = .init(
//        load: { [] },
//        add: { _ in },
//        remove: { _ in }
//    )
//}
//
//public extension DependencyValues {
//    public var bookmarksClient: BookmarksClient {
//        get { self[BookmarksClient.self] }
//        set { self[BookmarksClient.self] = newValue }
//    }
//}
