//
//  SearchReducer.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/14/25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct SearchReducer {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var query: String = ""
        var hasSearched: Bool = false

        var viewDisplayMode: ViewDisplayMode<[Film]> = .empty(message: "Search for films or news.")
        var films: IdentifiedArrayOf<Film> = []

        var isLoadingPage = false
        var currentPage = 1
        var canLoadMore = false
        var loadedFilmIDs: Set<Int> = []
        var errorMessage: String?

        var recentSearches: [String] = []

        @Presents var destination: Destination.State?

    }

    @Reducer(state: .equatable)
    public enum Destination {
        case filmDetail(FilmDetailReducer)
    }

    public enum Action: BindableAction {
        case onAppear

        case submitTapped
        case onSubmit
        case clearQueryTapped

        case recentSearchTapped(String)
        case clearHistoryTapped

        case loadNextPage
        case pageResponse(Result<[Film], Error>)

        case filmTapped(Film)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.feedClient) var feedClient
    @Dependency(\.searchHistoryClient) var history

    private let pageLimit = 10
    private let maxRecent = 10

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.recentSearches = history.load()
                if !state.hasSearched, state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.viewDisplayMode = .empty(message: state.recentSearches.isEmpty
                        ? "Search for films or news."
                        : "Recent searches"
                    )
                }
                return .none

            case .binding:
                return .none

            case .clearQueryTapped:
                state.query = ""
                state.hasSearched = false
                state.films = []
                state.loadedFilmIDs = []
                state.currentPage = 1
                state.canLoadMore = false
                state.isLoadingPage = false
                state.errorMessage = nil
                state.viewDisplayMode = .empty(message: state.recentSearches.isEmpty ? "Search for films or news." : "Recent searches")
                return .none

            case .submitTapped, .onSubmit:
                let q = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !q.isEmpty else {
                    state.viewDisplayMode = .empty(message: state.recentSearches.isEmpty ? "Search for films or news." : "Recent searches")
                    return .none
                }

                // persist recent searches (dedupe + move-to-front)
                var recent = history.load()
                recent.removeAll { $0.caseInsensitiveCompare(q) == .orderedSame }
                recent.insert(q, at: 0)
                if recent.count > maxRecent { recent = Array(recent.prefix(maxRecent)) }
                history.save(recent)
                state.recentSearches = recent

                // reset results
                state.hasSearched = true
                state.viewDisplayMode = .loading
                state.films = []
                state.loadedFilmIDs = []
                state.currentPage = 1
                state.canLoadMore = true
                state.isLoadingPage = false
                state.errorMessage = nil

                return .send(.loadNextPage)

            case let .recentSearchTapped(term):
                state.query = term
                return .send(.submitTapped)

            case .clearHistoryTapped:
                history.save([])
                state.recentSearches = []
                if !state.hasSearched {
                    state.viewDisplayMode = .empty(message: "Search for films or news.")
                }
                return .none

            case .loadNextPage:
                guard state.hasSearched else { return .none }
                guard !state.isLoadingPage, state.canLoadMore else { return .none }

                let q = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !q.isEmpty else { return .none }

                state.isLoadingPage = true
                if state.films.isEmpty { state.viewDisplayMode = .loading }

                let page = state.currentPage
                let limit = pageLimit

                return .run { send in
                    do {
                        let films = try await feedClient.loadPage(.search(query: q), page, limit)
                        await send(.pageResponse(.success(films)))
                    } catch {
                        await send(.pageResponse(.failure(error)))
                    }
                }

            case let .pageResponse(.success(newFilms)):
                state.isLoadingPage = false

                let filtered = newFilms.filter { !state.loadedFilmIDs.contains($0.id) }
                filtered.forEach { state.loadedFilmIDs.insert($0.id) }
                state.films.append(contentsOf: filtered)

                if filtered.isEmpty {
                    state.canLoadMore = false
                } else {
                    state.currentPage += 1
                    state.canLoadMore = true
                }

                if state.films.isEmpty {
                    state.viewDisplayMode = .empty(message: "No results for “\(state.query)”.")
                } else {
                    state.viewDisplayMode = .content
                }
                return .none

            case let .pageResponse(.failure(error)):
                state.isLoadingPage = false
                state.errorMessage = error.localizedDescription
                if state.films.isEmpty {
                    state.viewDisplayMode = .error(message: error.localizedDescription)
                } else {
                    state.viewDisplayMode = .content
                }
                return .none

            case let .filmTapped(film):
                state.destination = .filmDetail(FilmDetailReducer.State(film: film))
                return .none

            case .destination(.dismiss):
                state.destination = nil
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

