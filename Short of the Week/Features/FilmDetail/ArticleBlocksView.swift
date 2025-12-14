//
//  ArticleBlocksView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI
import Foundation

struct ArticleBlocksView: View {
    let blocks: [ArticleBlock]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading(let level, let text):
                    Text(text)
                        .font(Font.custom("Dom Diagonal W03 Bd", size: headingSize(for: level)))
                        .foregroundStyle(Color(hex: "#272E2C"))
                        .padding(.top, level <= 2 ? 10 : 6)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)

                case .paragraph(let text):
                    Text(text)
                        .foregroundStyle(Color(hex: "#272E2C"))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                case .bulletedList(let bullets):
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(bullets.enumerated()), id: \.offset) { _, bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(Color(hex: "#272E2C"))
                                Text(bullet)
                                    .foregroundStyle(Color(hex: "#272E2C"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                case .image(let url, let caption):
                    VStack(alignment: .leading, spacing: 8) {
                        CachedAsyncImage(url: url, contentMode: .fit) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.08))
                                .frame(height: 180)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let caption, !caption.isEmpty {
                            Text(caption)
                                .font(.footnote)
                                .foregroundStyle(Color(hex: "#272E2C").opacity(0.7))
                                .italic()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
    
    private func headingSize(for level: Int) -> CGFloat {
        switch level {
        case 1: return 28
        case 2: return 22
        case 3: return 18
        default: return 16
        }
    }
}

#if DEBUG
import SwiftUI

#Preview("ArticleBlocksView – Seed[0] (raw)") {
    let film = SOTWSeed.sampleFilms.first!
    let blocks = ArticleParser.parse(film.articleHTML)

    return ScrollView {
        ArticleBlocksView(blocks: blocks)
            .padding(16)
    }
    .background(Color(hex: "#D7E0DB"))
    .preferredColorScheme(.dark)
}

#Preview("ArticleBlocksView – Seed[0] (normalized)") {
    let film = SOTWSeed.sampleFilms.first!
    let blocks = ArticleParser.parse(film.articleHTML.wrappingNormalized)

    return ScrollView {
        ArticleBlocksView(blocks: blocks)
            .padding(16)
    }
    .background(Color(hex: "#D7E0DB"))
    .preferredColorScheme(.dark)
}
#endif
