//
//  SearchClient.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/14/25.
//

import ComposableArchitecture
import Foundation

struct SearchClient {
    var load: @Sendable () -> [String]
    var save: @Sendable (_ items: [String]) -> Void
}

extension SearchClient: DependencyKey {
    static let liveValue: SearchClient = .init(
        load: {
            let key = "sotw.recentSearches.v1"
            guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        },
        save: { items in
            let key = "sotw.recentSearches.v1"
            let data = (try? JSONEncoder().encode(items)) ?? Data()
            UserDefaults.standard.set(data, forKey: key)
        }
    )

    static let testValue: SearchClient = .init(load: { [] }, save: { _ in })
}

extension DependencyValues {
    var searchHistoryClient: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}
