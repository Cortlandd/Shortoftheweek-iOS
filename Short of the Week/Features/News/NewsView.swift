//
//  NewsView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/13/25.
//

import SwiftUI
import ComposableArchitecture
import Perception

public struct NewsView: View {
    @Bindable public var store: StoreOf<NewsReducer>

    /// Used by iOS 17+ navigation hero transitions.
    @Namespace private var heroNamespace
    @State private var showDetailContent: Bool = false

    public init(store: StoreOf<NewsReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                switch store.viewDisplayMode {
                case .loading:
                    SOTWCustomLoader()

                case .error:
                    VStack(spacing: 12) {
                        Image("sotwNetworkErrorWhite")
                            .resizable()
                            .scaledToFit()
                            .padding(3)

                        Button {
                            store.send(.refreshPulled)
                        } label: {
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

                case .empty(let message):
                    VStack(spacing: 0) {
                        Spacer()

                        VStack(spacing: 12) {
                            Text(message)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray.opacity(0.92))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Button {
                                store.send(.refreshPulled)
                            } label: {
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
            store.scope(state: \.$destination, action: \.destination)
        ) { destinationStore in
            SwitchStore(destinationStore) { initialState in 
                CaseLet(
                    /NewsReducer.Destination.State.filmDetail,
                    action: NewsReducer.Destination.Action.filmDetail
                ) { filmDetailStore in
                    let filmID = filmDetailStore.withState { $0.film.id }
                    FilmDetailView(
                        store: filmDetailStore,
                        namespace: heroNamespace,
                        showDetailContent: $showDetailContent,
                        onClose: {
                            showDetailContent = false
                            _ = store.send(.destination(.dismiss))
                        }
                    )
                    .navigationTransition(.zoom(sourceID: "news-hero-\(filmID)", in: heroNamespace))
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
                    NewsRow(
                        film: film,
                        namespace: heroNamespace,
                        onTap: {
                            showDetailContent = false
                            store.send(.filmTapped(film))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    showDetailContent = true
                                }
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
}

// MARK: - Row (News)

private struct NewsRow: View {
    let film: Film
    let namespace: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            NewsHeroCardView(film: film, namespace: namespace)
        }
        .buttonStyle(.plain)
    }
}

/// News-only hero card. Keeps text bounded inside the thumbnail.
private struct NewsHeroCardView: View {
    let film: Film
    let namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .bottom) {
            heroImage
                .matchedTransitionSource(id: "news-hero-\(film.id)", in: namespace)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.90)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            overlay
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .clipped()
    }

    private var heroImage: some View {
        // News: prefer thumbnail first.
        let url: URL? = film.thumbnailURL ?? film.backgroundImageURL

        return Group {
            if let url {
                CachedAsyncImage(url: url, contentMode: .fill) {
                    Color.black.opacity(0.35)
                }
            } else {
                Color.black.opacity(0.35)
            }
        }
    }

    private var overlay: some View {
        VStack(spacing: 8) {
            if let meta = metadataLine {
                Text(meta.uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Text(film.title.uppercased())
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
                // Ensures the title never renders outside the card
                .frame(maxWidth: 420)

            if let excerpt = film.synopsis, !excerpt.isEmpty {
                Text(excerpt)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: 520)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var metadataLine: String? {
        var parts: [String] = []
        if let cat = film.headerCategoryLabel { parts.append(cat) }
        if let date = film.postDate {
            parts.append(date.formatted(.dateTime.month(.wide).day().year()))
        }
        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}

#if DEBUG
import SwiftUI
import ComposableArchitecture

#Preview("NewsView – Loading") {
    NewsView(
        store: Store(
            initialState: {
                var s = NewsReducer.State()
                s.viewDisplayMode = .loading
                return s
            }(),
            reducer: { NewsReducer() }
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("NewsView – Empty") {
    NewsView(
        store: Store(
            initialState: {
                var s = NewsReducer.State()
                s.viewDisplayMode = .empty(message: "No news found.")
                return s
            }(),
            reducer: { NewsReducer() }
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("NewsView – Error") {
    NewsView(
        store: Store(
            initialState: {
                var s = NewsReducer.State()
                s.viewDisplayMode = .error(message: "Network error")
                return s
            }(),
            reducer: { NewsReducer() }
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("NewsView – Content") {
    NewsView(
        store: Store(
            initialState: {
                var s = NewsReducer.State()
                s.viewDisplayMode = .content
                // Prefer actual news seed data if you generated it; fall back to films.
                s.films = IdentifiedArrayOf(uniqueElements: SOTWSeed.sampleFilms)
                s.canLoadMore = true
                s.isLoadingPage = false
                return s
            }(),
            reducer: { NewsReducer() }
        )
    )
    .preferredColorScheme(.dark)
}
#endif
