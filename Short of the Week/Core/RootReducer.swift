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
    }

    enum Action: BindableAction {
        case task
        case selectTab(RootReducer.Tab)
        case splashFinished
        case home(HomeReducer.Action)
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.home, action: \.home) { HomeReducer() }

        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                  try? await Task.sleep(nanoseconds: 900_000_000) // adjust
                  await send(.splashFinished)
                }
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none

            case .splashFinished:
                state.showSplash = false
                return .none

            case .home:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
