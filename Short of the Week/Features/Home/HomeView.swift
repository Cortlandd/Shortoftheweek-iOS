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

                    feedScrollView

                    heroDetailOverlay
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear { store.send(.onAppear) }
            .refreshable { store.send(.refreshPulled) }
        }
    }

    private var feedScrollView: some View {
        let films: IdentifiedArrayOf<Film> = store.films

        let selectedFilmID: Int? = {
            guard let destination = store.destination else { return nil }
            if case let .filmDetail(state) = destination { return state.film.id }
            return nil
        }()

        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(films, id: \.id) { film in
                    FilmRow(
                        film: film,
                        selectedFilmID: selectedFilmID,
                        onTap: {
                            showDetailContent = false

                            withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.9, blendDuration: 0.2)) {
                                store.send(.filmTapped(film))
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    showDetailContent = true
                                }
                            }
                        },
                        namespace: heroNamespace
                    )
                }

                if store.canLoadMore {
                    Button {
                        store.send(.loadNextPage)
                    } label: {
                        Text(store.isLoadingPage ? "LOADING…" : "MORE")
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

    @ViewBuilder
    private var heroDetailOverlay: some View {
        IfLetStore(
            store.scope(
                state: \.$destination,
                action: HomeReducer.Action.destination
            )
        ) { destinationStore in
            SwitchStore(destinationStore) { initialState in
                CaseLet(
                    /HomeReducer.Destination.State.filmDetail,
                    action: HomeReducer.Destination.Action.filmDetail
                ) { filmDetailStore in
                    FilmDetailViewWrapper(
                        store: filmDetailStore,
                        namespace: heroNamespace,
                        showDetailContent: $showDetailContent,
                        onClose: {
                            withAnimation(.easeOut(duration: 0.12)) {
                                showDetailContent = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.92, blendDuration: 0.2)) {
                                    _ = store.send(.destination(.dismiss))
                                }
                            }
                        }
                    )
                    .zIndex(10)
                }
            }
        }
    }
}

// MARK: - Row

private struct FilmRow: View {
    let film: Film
    let selectedFilmID: Int?
    let onTap: () -> Void
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HomeHeroCardView(film: film, namespace: namespace)
                    .opacity(selectedFilmID == film.id ? 0.0 : 1.0)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color.white)
                .frame(height: 0)
        }
    }
}

// MARK: - Home Hero Card

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
                .matchedGeometryEffect(id: "hero-image-\(film.id)", in: namespace)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // ✅ Home owns its overlay logic.
            HomeHeroCardOverlay(film: film)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .clipped()
    }

    private var heroImage: some View {
        // ✅ Home owns thumbnail selection:
        // - News: prefer thumbnail (often "article" style imagery)
        // - Films: prefer background image (cinematic)
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
        Color.clear.overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer(minLength: 0)

                    VStack(alignment: .center, spacing: 8) {
                        if let metadataLine {
                            Text(metadataLine.uppercased())
                                .font(Font.custom("Dom Diagonal W03 Bd", size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }

                        Text(film.title.uppercased())
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)

                        if let synopsis = film.synopsis, !synopsis.isEmpty {
                            Text(synopsis)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: 420, alignment: .center)

                    Spacer(minLength: 0)
                }
                Spacer()
            }
        )
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

// MARK: - Wrapper

private struct FilmDetailViewWrapper: View {
    let store: StoreOf<FilmDetailReducer>
    let namespace: Namespace.ID
    @Binding var showDetailContent: Bool
    let onClose: () -> Void

    var body: some View {
        FilmDetailView(
            store: store,
            namespace: namespace,
            showDetailContent: $showDetailContent,
            onClose: onClose
        )
    }
}

// MARK: - Previews

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
            $0.feedClient.loadPage = { _, _, _ in
                return SOTWSeed.sampleFilms
            }
        }
    )
}

#Preview("HomeView - Loading") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(
                viewDisplayMode: .loading,
                films: IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms)
            )
        ) {
            HomeReducer()
        }
    )
}

#Preview("HomeView - Empty") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(
                viewDisplayMode: .empty(message: "No films found."),
                films: IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms),
                canLoadMore: false
            )
        ) {
            HomeReducer()
        }
    )
}

#Preview("HomeView - Error") {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(
                viewDisplayMode: .error(message: "Network request failed."),
                films: IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms),
                canLoadMore: false
            )
        ) {
            HomeReducer()
        }
    )
}
