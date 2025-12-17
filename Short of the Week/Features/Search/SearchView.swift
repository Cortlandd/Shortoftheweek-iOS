//
//  SearchView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/14/25.
//

import ComposableArchitecture
import Perception
import SwiftUI

public struct SearchView: View {
    @Bindable public var store: StoreOf<SearchReducer>
    @Environment(\.dismiss) private var dismissKeyboard

    @Namespace private var heroNamespace
    @State private var selectedID: Int? = nil
    @State private var showDetailContent: Bool = false

    public init(store: StoreOf<SearchReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchHeader
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                    switch store.viewDisplayMode {
                    case .loading:
                        SOTWCustomLoader()

                    case .error:
                        VStack(spacing: 12) {
                            Image("sotwNetworkErrorWhite")
                                .resizable()
                                .scaledToFit()
                                .padding(3)

                            Button { store.send(.submitTapped) } label: {
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

                    case .empty:
                        emptyOrRecent

                    case .content:
                        resultsList
                    }
                }
            }
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
                heroDetailOverlay
            }
            .background(Color(hex: "#D7E0DB"))
            .onTapGesture(perform: {
                dismissKeyboard()
            })
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Header

    private var searchHeader: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.7))

                TextField("Search...", text: $store.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .foregroundColor(.white)
                    .foregroundStyle(.white)
                    .submitLabel(.search)
                    .onSubmit { store.send(.onSubmit) }

                if !store.query.isEmpty {
                    Button { store.send(.clearQueryTapped) } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(hex: "#272E2C").opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                store.send(.submitTapped)
            } label: {
                Text("Go")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Empty / Recent

    private var emptyOrRecent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if !store.recentSearches.isEmpty {
                    HStack {
                        Text("RECENT")
                            .font(Font.custom("Dom Diagonal W03 Bd", size: 16))
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Button("Clear") { store.send(.clearHistoryTapped) }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    VStack(spacing: 10) {
                        ForEach(store.recentSearches, id: \.self) { term in
                            Button {
                                store.send(.recentSearchTapped(term))
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.white.opacity(0.7))
                                    Text(term)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .foregroundStyle(.white.opacity(0.65))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Text("Search for films or news.")
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                    }
                }

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
        }
    }

    // MARK: - Results list

    private var resultsList: some View {
        let films: IdentifiedArrayOf<Film> = store.films

        let selectedFilmID: Int? = {
            guard let destination = store.destination else { return nil }
            if case let .filmDetail(state) = destination { return state.film.id }
            return nil
        }()

        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(films, id: \.id) { film in
                    Button {
                        showDetailContent = false
                        withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.9, blendDuration: 0.2)) {
                            store.send(.filmTapped(film))
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                            withAnimation(.easeOut(duration: 0.2)) { showDetailContent = true }
                        }
                    } label: {
                        SearchResultCard(film: film, namespace: heroNamespace)
                            .opacity(selectedFilmID == film.id ? 0.0 : 1.0)
                    }
                    .buttonStyle(.plain)

                    Rectangle().fill(Color.white).frame(height: 0)
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
        .scrollDismissesKeyboard(.immediately)
    }

    // MARK: - Detail overlay

    @ViewBuilder
    private var heroDetailOverlay: some View {
        IfLetStore(
            store.scope(state: \.$destination, action: SearchReducer.Action.destination)
        ) { destinationStore in
            SwitchStore(destinationStore) { _ in
                CaseLet(
                    /SearchReducer.Destination.State.filmDetail,
                    action: SearchReducer.Destination.Action.filmDetail
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
                    .navigationTransition(.zoom(sourceID: "home-hero-\(filmID)", in: heroNamespace))
                }
            }
        }
    }
}

// MARK: - Card (keeps text inside thumbnail)

private struct SearchResultCard: View {
    let film: Film
    let namespace: Namespace.ID

    var body: some View {
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

            VStack(alignment: .center, spacing: 8) {

                Spacer()
                
                if let meta = metadataLine {
                    Text(meta.uppercased())
                        .font(Font.custom("Dom Diagonal W03 Bd", size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }

                Text(film.title.uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 20))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 420)

                if let synopsis = film.synopsis, !synopsis.isEmpty {
                    Text(synopsis)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(4)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .clipped()
    }

    private var heroImage: some View {
        let url: URL? = film.isNews
            ? (film.thumbnailURL ?? film.backgroundImageURL)
            : (film.backgroundImageURL ?? film.thumbnailURL)

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


// MARK: - Previews

#Preview("SearchView – Recent") {
    SearchView(
        store: Store(
            initialState: {
                var s = SearchReducer.State()
                s.recentSearches = ["no vacancy", "hothouse", "animation", "vimeo"]
                s.viewDisplayMode = .empty(message: "Recent searches")
                return s
            }()
        ) { SearchReducer() }
    )
    .preferredColorScheme(.dark)
}

#Preview("SearchView – Results") {
    SearchView(
        store: Store(
            initialState: {
                var s = SearchReducer.State()
                s.query = "no vacancy"
                s.hasSearched = true
                s.viewDisplayMode = .content
                s.films = IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms)
                s.canLoadMore = true
                return s
            }()
        ) { SearchReducer() }
    )
    .preferredColorScheme(.dark)
}

