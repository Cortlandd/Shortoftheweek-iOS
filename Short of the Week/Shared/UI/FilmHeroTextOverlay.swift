//
//  FilmHeroTextOverlay.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI

/// Shared hero-card text overlay so Home + Bookmarks can reuse the same layout.
///
/// This also fixes the "infinite width" issue where some titles looked like they
/// were spanning the full thumbnail.
public struct FilmHeroTextOverlay: View {
    public enum Alignment {
        case leading
        case center
    }

    public var isPlaying: Bool = false
    public let film: Film
    public let alignment: Alignment
    
    public init(isPlaying: Bool = false, film: Film, alignment: Alignment) {
        self.isPlaying = isPlaying
        self.film = film
        self.alignment = alignment
    }

    public var body: some View {
        Color.clear // Use a background color or image here if needed.
            .overlay(
                VStack { // Outer VStack for vertical centering
                    Spacer() // Pushes content down
                    HStack { // Outer HStack for horizontal centering
                        if alignment == .center {
                            Spacer(minLength: 0)
                        }

                        VStack(alignment: alignment == .center ? .center : .leading, spacing: 8) {
                            if isPlaying {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(22)
                                    .background(Color.black.opacity(0.55))
                                    .clipShape(Circle())
                                    .accessibilityLabel("Play Button")
                            }

                            if let metadataLine {
                                Text(metadataLine.uppercased())
                                    .font(.system(size: 11, weight: .semibold))
                                    .kerning(1.2)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(alignment == .center ? .center : .leading)
                                    .italic()
                            }

                            Text(film.title.uppercased())
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .italic()
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(alignment == .center ? .center : .leading)

                            if let synopsis = film.synopsis, !synopsis.isEmpty, !film.isNews {
                                Text(synopsis)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(3)
                                    .multilineTextAlignment(alignment == .center ? .center : .leading)
                            }
                        }
                        .frame(maxWidth: alignment == .center ? 420 : .infinity, alignment: alignment == .center ? .center : .leading)

                        if alignment == .center {
                            Spacer(minLength: 0)
                        }
                    }
                    Spacer()
                }
            )
    }
    
    private var dateLabel: String? {
        guard let d = film.postDate else { return nil }
        return d.formatted(.dateTime.month(.wide).day().year())
    }
    
    private var metadataLine: String? {
        var parts: [String] = []
        
        if film.isNews {
            if let cat = film.headerCategoryLabel {
                parts.append(cat)
            }
            
            if let date = film.postDate {
                let d = date.formatted(.dateTime.month(.wide).day().year())
                parts.append(d)
            }
        } else {
            if let genre = film.genre?.displayName, !genre.isEmpty {
                parts.append(genre)
            }

            if let filmmaker = film.filmmaker, !filmmaker.isEmpty {
                parts.append(filmmaker)
            }

            if let minutes = film.durationMinutes, minutes > 0 {
                let label = minutes == 1 ? "1 MINUTE" : "\(minutes) MINUTES"
                parts.append(label)
            }

        }
        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }
}
