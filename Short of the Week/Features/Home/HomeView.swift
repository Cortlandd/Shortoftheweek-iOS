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
                Color.black.ignoresSafeArea()

                feedScrollView

                heroDetailOverlay
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    private var feedScrollView: some View {
        // Help the type-checker by creating a local constant with explicit type. thx xcode
        let films: IdentifiedArrayOf<Film> = store.films

        return ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(films, id: \.id) { film in
                    FilmRow(
                        film: film,
                        onTap: {
                            // Start hero transition
                            showDetailContent = false

                            withAnimation(.interactiveSpring(response: 0.48, dampingFraction: 0.9, blendDuration: 0.2)) {
                                store.send(.filmTapped(film))
                            }

                            // Reveal the video/article shortly after expand begins
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    showDetailContent = true
                                }
                            }
                        },
                        namespace: heroNamespace
                    )
                }

                if store.isLoadingPage {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity)
                }

                // "More" button like the website
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

                if let error = store.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .refreshable {
            store.send(.refreshPulled)
        }
    }

    @ViewBuilder
    private var heroDetailOverlay: some View {
        // We keep your Destination-based navigation state, but render it as an overlay instead of a sheet.
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
                            // Hide content first (so video/article fade out), then collapse hero
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
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
        }
    }
}

/// Extracted to reduce generic depth in the main body.
private struct FilmRow: View {
    let film: Film
    let onTap: () -> Void
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HomeHeroCardView(film: film, namespace: namespace)
            }
            .buttonStyle(.plain)

            // White separator between cards
            Rectangle()
                .fill(Color.white)
                .frame(height: 0)
        }
    }
}

/// Full-bleed hero card like the mobile website.
public struct HomeHeroCardView: View {
    public let film: Film
    public let namespace: Namespace.ID

    public init(film: Film, namespace: Namespace.ID) {
        self.film = film
        self.namespace = namespace
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image (this is what expands)
            heroImage
                .matchedGeometryEffect(id: "hero-image-\(film.id)", in: namespace)

            // Dark gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // Text content
            FilmHeroTextOverlay(
                film: film,
                alignment: .center
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .clipped()
    }

    private var heroImage: some View {
        Group {
            if let url = film.backgroundImageURL ?? film.thumbnailURL {
                CachedAsyncImage(url: url, contentMode: .fill) {
                    Color.black.opacity(0.4)
                }
            } else {
                Color.black.opacity(0.4)
            }
        }
    }
}

/// Wrapper to keep the generic Store type local and simple.
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

//#Preview {
//    HomeView(
//        store: Store(
//            initialState: HomeReducer.State(
//                films: IdentifiedArray(uniqueElements: SOTWSeed.sampleFilms)
//            )
//        ) {
//            HomeReducer()
//        } withDependencies: {
//            $0.feedClient.loadPage = { _, _ in
//                SOTWSeed.sampleFilms
//            }
//        }, logoNS: <#Namespace.ID#>
//    )
//}
