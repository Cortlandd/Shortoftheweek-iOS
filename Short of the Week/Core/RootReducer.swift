//
//  RootReducer.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct RootReducer {
    enum Tab: Equatable, Hashable, Sendable {
        case home
        case news
        case search
    }

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
      
        var showSplash = true
        var home = HomeReducer.State()
        var news = NewsReducer.State()
    }

    enum Action: BindableAction {
        case onAppear
        case selectTab(RootReducer.Tab)
        case splashFinished
        case home(HomeReducer.Action)
        case news(NewsReducer.Action)
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.home, action: \.home) { HomeReducer() }
        Scope(state: \.news, action: \.news) { NewsReducer() }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none

            case .splashFinished:
                state.showSplash = false
                return .none

            case .home, .news:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
