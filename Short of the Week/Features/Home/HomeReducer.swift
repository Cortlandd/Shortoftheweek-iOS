//
//  Home.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import ComposableArchitecture
import Foundation

/// Home feature: shows the paginated feed of films/articles.
@Reducer
public struct HomeReducer {
    public init() {}

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        /// All films loaded so far.
        var films: IdentifiedArrayOf<Film> = []

        /// For simple pagination.
        var isLoadingPage = false
        var currentPage = 1
        var canLoadMore = true

        /// In case the API sometimes repeats items across pages.
        var loadedFilmIDs: Set<Int> = []

        /// Optional error string you can surface in the UI if you want.
        var errorMessage: String?

        /// Presentation: FilmDetailReducer sheet.
        @Presents var destination: Destination.State?
    }

    // MARK: - Destination

    @Reducer(state: .equatable)
    public enum Destination {
        case filmDetail(FilmDetailReducer)
    }

    // MARK: - Actions

    public enum Action: BindableAction {
        case onAppear
        case refreshPulled

        case loadNextPage
        case pageResponse(Result<[Film], Error>)

        case filmTapped(Film)
        case dismissDetailTapped

        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }

    // MARK: - Dependencies

    @Dependency(\.feedClient) var feedClient

    // MARK: - Reducer

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {

            // Initial load
            case .onAppear:
                guard state.films.isEmpty else { return .none }
                return .send(.loadNextPage)
            case .binding:
                return .none

            case .refreshPulled:
                state.films = []
                state.loadedFilmIDs = []
                state.currentPage = 1
                state.canLoadMore = true
                state.errorMessage = nil
                return .send(.loadNextPage)

            case .loadNextPage:
                guard !state.isLoadingPage, state.canLoadMore else {
                    return .none
                }

                state.isLoadingPage = true
                state.errorMessage = nil
                let page = state.currentPage
                let limit = 10

                return .run { send in
                    do {
                        let films = try await feedClient.loadPage(page, limit)
                        await send(.pageResponse(.success(films)))
                    } catch {
                        await send(.pageResponse(.failure(error)))
                    }
                }

            case let .pageResponse(.success(newFilms)):
                state.isLoadingPage = false

                // Deduplicate by film ID to guard against overlapping pages.
                let filtered = newFilms.filter { !state.loadedFilmIDs.contains($0.id) }
                filtered.forEach { state.loadedFilmIDs.insert($0.id) }
                state.films.append(contentsOf: filtered)

                if filtered.isEmpty {
                    state.canLoadMore = false
                } else {
                    state.currentPage += 1
                }

                return .none    

            case let .pageResponse(.failure(error)):
                state.isLoadingPage = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .filmTapped(film):
                state.destination = .filmDetail(FilmDetailReducer.State(film: film))
                return .none

            case .dismissDetailTapped:
                  state.destination = nil
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
