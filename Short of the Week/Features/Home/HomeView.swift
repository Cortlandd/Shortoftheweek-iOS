//
//  HomeView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import ComposableArchitecture
import Perception
import SwiftUI

public struct HomeView: View {
    @Bindable public var store: StoreOf<HomeReducer>

    /// Used by iOS 17+ navigation hero transitions.
    @Namespace private var heroNamespace
    @State private var showDetailContent: Bool = false

    public init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                switch store.viewDisplayMode {
                case .loading:
                    SOTWCustomLoader()

                case .error:
                    errorView

                case .empty(let message):
                    emptyView(message: message)

                case .content:
                    Color.black.ignoresSafeArea()
                    feedScrollView
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear { store.send(.onAppear) }
            .refreshable { store.send(.refreshPulled) }
            .navigationDestination(
                isPresented: Binding(
                    get: { store.destination != nil },
                    set: { isPresented in
                        if !isPresented {
                            _ = store.send(.destination(.dismiss))
                        }
                    }
                )
            ) {
                destinationView
            }
        }
    }

    // MARK: - Destination

    @ViewBuilder
    private var destinationView: some View {
        IfLetStore(
            store.scope(state: \.$destination, action: HomeReducer.Action.destination)
        ) { destinationStore in
            SwitchStore(destinationStore) { initialState in 
                CaseLet(
                    /HomeReducer.Destination.State.filmDetail,
                    action: HomeReducer.Destination.Action.filmDetail
                ) { filmDetailStore in
                    let filmID = filmDetailStore.withState { $0.film.id }
                    FilmDetailView(
                        store: filmDetailStore,
                        namespace: heroNamespace,
                        showDetailContent: $showDetailContent,
                        onClose: {
                            // When the user taps X, pop the navigation destination.
                            showDetailContent = false
                            _ = store.send(.destination(.dismiss))
                        }
                    )
                    // iOS 17+ hero transition (replaces matchedGeometryEffect overlay approach)
                    .navigationTransition(.zoom(sourceID: "home-hero-\(filmID)", in: heroNamespace))
                }
            }
        }
    }

    // MARK: - Content

    private var feedScrollView: some View {
        let films: IdentifiedArrayOf<Film> = store.films

        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(films, id: \.id) { film in
                    FilmRow(
                        film: film,
                        namespace: heroNamespace,
                        onTap: {
                            showDetailContent = false
                            store.send(.filmTapped(film))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                showDetailContent = true
                            }
                        }
                    )
                }

                if store.canLoadMore {
                    Button {
                        store.send(.loadNextPage)
                    } label: {
                        Text(store.isLoadingPage ? "LOADING..." : "MORE")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                    .disabled(store.isLoadingPage)
                }
            }
        }
    }

    // MARK: - Error / Empty

    private var errorView: some View {
        VStack(spacing: 12) {
            Image("sotwNetworkErrorWhite")
                .resizable()
                .scaledToFit()
                .padding(3)

            Button { store.send(.refreshPulled) } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#272E2C").opacity(0.50))
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyView(message: String) -> some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                Text(message)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button { store.send(.refreshPulled) } label: {
                    Text("Retry")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#272E2C").opacity(0.50))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .cornerRadius(10)
                }
            }
            Spacer()
            Image("sotwEmpty")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color.white)
    }
}

// MARK: - Row

private struct FilmRow: View {
    let film: Film
    let namespace: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HomeHeroCardView(film: film, namespace: namespace)
            }
            .buttonStyle(.plain)
            Rectangle()
                .fill(Color.white)
                .frame(height: 0)
        }
    }
}

// MARK: - Hero Card

public struct HomeHeroCardView: View {
    public let film: Film
    public let namespace: Namespace.ID

    public init(film: Film, namespace: Namespace.ID) {
        self.film = film
        self.namespace = namespace
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroImage
                .matchedTransitionSource(id: "home-hero-\(film.id)", in: namespace)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            HomeHeroCardOverlay(film: film)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipped()
    }

    private var heroImage: some View {
        // Home: news tends to have better thumbnails; films tend to have better background images.
        let url: URL? = film.isNews
            ? (film.thumbnailURL ?? film.backgroundImageURL)
            : (film.backgroundImageURL ?? film.thumbnailURL)

        return Group {
            if let url {
                CachedAsyncImage(url: url, contentMode: .fill) {
                    Color.black.opacity(0.4)
                }
            } else {
                Color.black.opacity(0.4)
            }
        }
    }
}

private struct HomeHeroCardOverlay: View {
    let film: Film

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer(minLength: 0)
                VStack(alignment: .center, spacing: 8) {
                    if let metadataLine {
                        Text(metadataLine.uppercased())
                            .font(Font.custom("Dom Diagonal W03 Bd", size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }

                    Text(film.title.uppercased())
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)

                    if let synopsis = film.synopsis, !synopsis.isEmpty {
                        Text(synopsis)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .lineLimit(4)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: 420)
                Spacer(minLength: 0)
            }
            Spacer()
        }
    }

    private var metadataLine: String? {
        var parts: [String] = []
        if film.isNews {
            if let cat = film.headerCategoryLabel { parts.append(cat) }
            if let date = film.postDate {
                parts.append(date.formatted(.dateTime.month(.wide).day().year()))
            }
        } else {
            if let genre = film.genre?.displayName, !genre.isEmpty { parts.append(genre) }
            if let filmmaker = film.filmmaker, !filmmaker.isEmpty { parts.append(filmmaker) }
            if let minutes = film.durationMinutes, minutes > 0 {
                parts.append(minutes == 1 ? "1 MINUTE" : "\(minutes) MINUTES")
            }
        }
        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}

#if DEBUG
import SwiftUI
import ComposableArchitecture

#Preview("HomeView - Content") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(
                viewDisplayMode: .content,
                films: IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms)
            )
        ) {
            HomeReducer()
        } withDependencies: {
            $0.feedClient.loadPage = { _, _, _ in SOTWSeed.sampleFilms }
        }
    )
}

#Preview("HomeView - Loading") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(viewDisplayMode: .loading)
        ) { HomeReducer() }
    )
}

#Preview("HomeView - Empty") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(viewDisplayMode: .empty(message: "No films found."))
        ) { HomeReducer() }
    )
}

#Preview("HomeView - Error") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(viewDisplayMode: .error(message: "Network request failed."))
        ) { HomeReducer() }
    )
}
#endif
