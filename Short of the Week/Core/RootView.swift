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
                TabView(selection: $store.selectedTab.sending(\.selectTab)) {
                    Tab("Home", systemImage: "house.fill", value: RootReducer.Tab.home) {
                        NavigationStack {
                            HomeView(store: store.scope(state: \.home, action: \.home))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        if !store.home.isShowingDetail {
                                            Image("sotwLogoTransparent")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 50)
                                                .accessibilityLabel("Home Icon")
                                        } else {
                                            // The HomeView toolbar item will be hidden during presentation
                                            EmptyView()
                                        }
                                    }
                                }
                        }
                    }
                    Tab("News", systemImage: "newspaper.fill", value: RootReducer.Tab.news) {
                        NavigationStack {
                            NewsView(store: store.scope(state: \.news, action: \.news))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Image("newsBanner")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                            .accessibilityLabel("News Icon")
                                    }
                                }
                        }
                    }
                    Tab("Search", systemImage: "magnifyingglass", value: RootReducer.Tab.search) {
                        NavigationStack {
                            SearchView(store: store.scope(state: \.search, action: \.search))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Image("sotwLogoTransparent")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                            .accessibilityLabel("Search Icon")
                                    }
                                }
                        }
                    }
                }
                .transition(.opacity)
            }
            .background(Color(hex: "#272E2C").opacity(0.92))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension HomeReducer.State {
    var isShowingDetail: Bool {
        if case .some(.filmDetail) = destination { return true }
        return false
    }
}

#if DEBUG
import SwiftUI
import ComposableArchitecture

#Preview("RootView – Splash") {
    RootView(
        store: Store(
            initialState: RootReducer.State(
                selectedTab: .home,
                showSplash: true,
                home: HomeReducer.State(),
                news: NewsReducer.State()
            ),
            reducer: { RootReducer() }
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("RootView – Tabs") {
    RootView(
        store: Store(
            initialState: RootReducer.State(
                selectedTab: .news,
                showSplash: false,
                home: HomeReducer.State(),
                news: {
                    var s = NewsReducer.State()
                    s.viewDisplayMode = .content
                    s.films = IdentifiedArrayOf(uniqueElements: SOTWSeed.sampleFilms)
                    s.canLoadMore = true
                    s.isLoadingPage = false
                    return s
                }()
            ),
            reducer: { RootReducer() }
        )
    )
    .preferredColorScheme(.dark)
}
#endif
