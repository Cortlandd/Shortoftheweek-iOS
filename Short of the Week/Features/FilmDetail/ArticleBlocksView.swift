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
                case .paragraph(let attr):
                    Text(attr)
                        .foregroundStyle(Color(hex: "#272E2C"))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

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
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
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
    .background(Color.black)
    .preferredColorScheme(.dark)
}

#Preview("ArticleBlocksView – Seed[0] (normalized)") {
    let film = SOTWSeed.sampleFilms.first!
    let blocks = ArticleParser.parse(film.articleHTML.wrappingNormalized)

    return ScrollView {
        ArticleBlocksView(blocks: blocks)
            .padding(16)
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
#endif
