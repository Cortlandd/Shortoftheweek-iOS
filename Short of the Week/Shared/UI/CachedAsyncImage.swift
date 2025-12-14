//
//  CachedAsyncImage.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI
import UIKit

/// A lightweight image loader that cooperates with URLCache.
///
/// `AsyncImage` can sometimes behave poorly under fast scrolling (lots of tasks,
/// cancellations, re-fetches). This keeps it predictable, and uses our cached
/// URLSession.
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL
    let contentMode: ContentMode
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var image: Image? = nil

    init(
        url: URL,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            // Avoid reloading if we already have the image.
            if image != nil { return }
            do {
                let request = NetworkSession.request(url: url)
                let (data, _) = try await NetworkSession.shared.data(for: request)
                let uiImage = await Task.detached {
                    UIImage(data: data)
                }.value
                if let uiImage {
                    await MainActor.run {
                        self.image = Image(uiImage: uiImage)
                    }
                }
            } catch {
                // Fail silently: placeholder remains.
            }
        }
    }
}
