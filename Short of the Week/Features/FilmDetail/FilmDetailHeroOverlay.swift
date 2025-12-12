//
//  FilmDetailHeroOverlay.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI

/// Overlay shown on the FilmDetail hero thumbnail before the embed player is revealed.
///
/// Tapping anywhere in the hero area should reveal the embed, but this keeps an explicit
/// play button for clarity.
import SwiftUI

struct FilmDetailHeroOverlay: View {
    let film: Film
    let onPlayTapped: () -> Void
    
    private var metadataLine: String? {
        var parts: [String] = []

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

        return parts.isEmpty ? nil : parts.joined(separator: " / ")
    }

    var body: some View {
        ZStack {
            // Slight dim so the play button is visible even on bright posters.
            Color.black.opacity(0.15)

            VStack(spacing: 14) {
                Button(action: onPlayTapped) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(22)
                        .background(Color.black.opacity(0.55))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Play")

                // Centered text block under the play button (website-style)
                VStack(spacing: 6) {
                    if let director = film.filmmaker, !director.isEmpty {
                        Text("\(director.uppercased()) / \(film.durationMinutesText.uppercased())")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    } else {
                        Text(film.durationMinutesText.uppercased())
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Text(film.title.uppercased())
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 18)
            }
        }
        .allowsHitTesting(true)
    }
}

// MARK: - Small helper for consistent duration formatting
private extension Film {
    var durationMinutesText: String {
        // Adjust if your Film model uses a different property name/type.
        if let durationMinutes, !durationMinutes.description.isEmpty {
            return "\(durationMinutes) MINUTES"
        }
        return ""
    }
}
