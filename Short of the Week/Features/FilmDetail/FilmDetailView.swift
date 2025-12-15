//
//  FilmDetailView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//
import ComposableArchitecture
import Perception
import SwiftUI

public struct FilmDetailView: View {
    @Bindable public var store: StoreOf<FilmDetailReducer>

    public let namespace: Namespace.ID
    @Binding public var showDetailContent: Bool
    public let onClose: () -> Void

    @State private var isVideoRevealed: Bool = false
    
    @State private var articleHeight: CGFloat = 1

    public init(
        store: StoreOf<FilmDetailReducer>,
        namespace: Namespace.ID,
        showDetailContent: Binding<Bool>,
        onClose: @escaping () -> Void
    ) {
        self.store = store
        self.namespace = namespace
        self._showDetailContent = showDetailContent
        self.onClose = onClose
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .top) {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        heroArea
                        
                        if store.film.kind == .video {
                            topicHeader
                            creditsHeader
                        }

                        if showDetailContent {
                            detailBody
                                .transition(.opacity)
                        } else {
                            // keep spacing stable during transition
                            Color.clear.frame(height: 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        EmptyView()
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            onClose()
                        } label: {
                            if #available(iOS 26.0, *) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(8)
                                    .contentShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 42, height: 42)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Close")
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .scrollIndicators(.hidden)
            }
            .toolbarVisibility(.hidden, for: .tabBar)
            .onAppear { store.send(.onAppear) }
            .onChange(of: store.film.id) { _, _ in
                // New film selected: reset the inline player.
                isVideoRevealed = false
            }
            .onChange(of: showDetailContent) { _, newValue in
                // If we're mid-transition back, keep the thumbnail visible next time.
                if !newValue { isVideoRevealed = false }
            }
        }
    }

    // MARK: - Hero area (image expands; video fades in over same region)

    private let heroHeight: CGFloat = 320

    private var heroArea: some View {
        GeometryReader { proxy in
            ZStack {
                if !isVideoRevealed {
                    heroImage
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                    // Navigation hero transition is now driven by `.navigationTransition(.zoom(...))`
                    // in the presenting view. We intentionally do not use matchedGeometryEffect here.

                // gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.05),
                        Color.black.opacity(0.45),
                        Color.black.opacity(0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
                
                if store.film.isNews {
                    // Centered overlay like the website hero.
                    FilmDetailNewsHeroOverlay(film: store.film)
                        .padding(.horizontal, 18)
                        .padding(.top, 32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .zIndex(2)
                } else {
                    // embedded video
                    if showDetailContent, let url = store.film.playURL, isVideoRevealed {
                        FilmVideoEmbedView(embedURL: url)
                            .transition(.opacity)
                            .zIndex(2)
                            .contentShape(Rectangle())
                            .allowsHitTesting(true)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }

                    // text + play button overlay
                    if showDetailContent, store.film.playURL != nil, !isVideoRevealed {
                        FilmDetailPlayHeroOverlay(film: store.film)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isVideoRevealed = true
                            }
                        }
                        .padding(.horizontal, 18)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .zIndex(2)
                    }
                }
            }
        }
        .frame(height: heroHeight)
    }


    private var heroImage: some View {
        Group {
            if let url = store.film.backgroundImageURL ?? store.film.thumbnailURL {
                CachedAsyncImage(url: url, contentMode: .fill) {
                    Color.black.opacity(0.35)
                }
            } else {
                Color.black.opacity(0.35)
            }
        }
    }
    
    // MARK: - Topic header
        
    private var topicHeader: some View {
        ZStack(alignment: .center) {
            HStack(spacing: 4) {
                if let genre = store.film.genre?.displayName, !genre.isEmpty {
                    Text(genre.uppercased())
                        .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.green.opacity(0.80))
                }
                
                Text("About".uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#95A6A1"))
                
                if let topic = store.film.topic?.displayName, !topic.isEmpty {
                    Text(topic.uppercased())
                        .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.orange.opacity(0.80))
                }
                
                Text("In".uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#95A6A1"))
                
                if let style = store.film.style?.displayName, !style.isEmpty {
                    Text(style.uppercased())
                        .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.pink.opacity(0.80))
                }
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#647370"))
        .multilineTextAlignment(.center)
    }

    // MARK: - Credit body

    private var creditsHeader: some View {
        VStack(spacing: 6) {
            if let director = store.film.filmmaker, !director.isEmpty {
                Text("Directed by \(director)".uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                    .fontWeight(.bold)
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: "#D7E0DB"))
            }

            if let producer = store.film.production, !producer.isEmpty {
                Text("Produced by \(producer)".uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                    .fontWeight(.bold)
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: "#D7E0DB"))
            }

            if let countryName = store.film.country?.displayName, !countryName.isEmpty {
                Text("Made in \(countryName)".uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 18))
                    .fontWeight(.bold)
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: "#D7E0DB"))
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#95A6A1"))
        .multilineTextAlignment(.center)
    }


    // MARK: - Detail body

    private var detailBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Author byline (News only)
            if store.film.isNews, let author = store.film.author {
                Text(author.displayName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(hex: "#272E2C").opacity(0.92))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }

            let normalizedHTML = store.film.articleHTML.wrappingNormalized
            let blocks = ArticleParser.parse(normalizedHTML)

            ArticleBlocksView(blocks: blocks)

            if let error = store.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer(minLength: 24)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#D7E0DB"))
    }

    // MARK: - Metadata

    private var metadataLine: String? {
        var parts: [String] = []
        if let genre = store.film.genre?.displayName, !genre.isEmpty { parts.append(genre) }
        if let filmmaker = store.film.filmmaker, !filmmaker.isEmpty { parts.append(filmmaker) }
        if let minutes = store.film.durationMinutes, minutes > 0 {
            parts.append(minutes == 1 ? "1 MINUTE" : "\(minutes) MINUTES")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}

// MARK: - Local hero overlays (no shared FilmHeroTextOverlay)

private struct FilmDetailNewsHeroOverlay: View {
    let film: Film

    var body: some View {
        VStack(spacing: 8) {
            if let metadataLine {
                Text(metadataLine.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
            }

            Text(film.title.uppercased())
                .font(Font.custom("Dom Diagonal W03 Bd", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)

            if let author = film.author {
                Text(author.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 480)
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

private struct FilmDetailPlayHeroOverlay: View {
    let film: Film

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "play.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(22)
                .background(Color.black.opacity(0.55))
                .clipShape(Circle())
                .accessibilityLabel("Play")

            if let metadataLine {
                Text(metadataLine.uppercased())
                    .font(Font.custom("Dom Diagonal W03 Bd", size: 14))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Text(film.title.uppercased())
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            if let synopsis = film.synopsis, !synopsis.isEmpty {
                Text(synopsis)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 480)
    }

    private var metadataLine: String? {
        var parts: [String] = []
        if let genre = film.genre?.displayName, !genre.isEmpty { parts.append(genre) }
        if let filmmaker = film.filmmaker, !filmmaker.isEmpty { parts.append(filmmaker) }
        if let minutes = film.durationMinutes, minutes > 0 {
            parts.append(minutes == 1 ? "1 MINUTE" : "\(minutes) MINUTES")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}

#Preview("FilmDetailView – No Vacancy (expanded)") {
    previewFilmDetail(index: 0, showDetail: true)
}

#Preview("FilmDetailView – Hello Stranger (expanded)") {
    previewFilmDetail(index: 1, showDetail: true)
}

#Preview("FilmDetailView – Sunshine City (expanded)") {
    previewFilmDetail(index: 2, showDetail: true)
}

#Preview("FilmDetailView – During Transition (content hidden)") {
    previewFilmDetail(index: 0, showDetail: false)
}

#Preview("FilmDetailView – News Article") {
    previewFilmDetail(index: 3, showDetail: true)
}

@MainActor
private func previewFilmDetail(index: Int, showDetail: Bool) -> some View {
    @Previewable @State var showDetailState = showDetail

    guard let film = SOTWSeed.sampleFilms[safe: index] ?? SOTWSeed.sampleFilms.first else {
        return AnyView(
            Text("No sample films configured.")
                .padding()
        )
    }

    let namespace = Namespace().wrappedValue

    return AnyView(
        FilmDetailView(
            store: Store(
                initialState: FilmDetailReducer.State(film: film)
            ) {
                FilmDetailReducer()
            },
            namespace: namespace,
            showDetailContent: $showDetailState,
            onClose: {}
        )
    )
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension String {
    var wrappingNormalized: String {
        self
            .replacingOccurrences(of: "\u{00A0}", with: " ") // nbsp
            .replacingOccurrences(of: "\u{202F}", with: " ") // narrow nbsp
            .replacingOccurrences(of: "\u{2007}", with: " ") // figure space
    }
}
