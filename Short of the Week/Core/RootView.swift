//
//  RootView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI
import ComposableArchitecture
import Perception

struct RootView: View {
  @Bindable var store: StoreOf<RootReducer>

  var body: some View {
    WithPerceptionTracking {
      ZStack {
        if store.showSplash {
          SplashView()
            .transition(.opacity)
            .zIndex(1)
        } else {
          NavigationStack {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                  ToolbarItem(placement: .principal) {
                      Image("sotwLogoTransparent")
                          .resizable()
                          .scaledToFill()
                          .frame(height: 50)
                          .accessibilityLabel("Short of the Week")
                  }
                }
          }
          .transition(.opacity)
        }
      }
      .task { await store.send(.task).finish() }
      .animation(.easeInOut(duration: 0.35), value: store.showSplash)
    }
  }
}
