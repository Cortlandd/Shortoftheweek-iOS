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

  @ObservableState
  struct State: Equatable {
    var showSplash = true
    var home = HomeReducer.State()
  }

  enum Action {
    case task
    case splashFinished
    case home(HomeReducer.Action)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.home, action: \.home) { HomeReducer() }

    Reduce { state, action in
      switch action {
      case .task:
        return .run { send in
          try? await Task.sleep(nanoseconds: 900_000_000) // adjust
          await send(.splashFinished)
        }

      case .splashFinished:
        state.showSplash = false
        return .none

      case .home:
        return .none
      }
    }
  }
}
