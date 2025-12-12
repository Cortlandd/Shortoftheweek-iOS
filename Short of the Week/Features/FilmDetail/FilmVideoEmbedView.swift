//
//  FilmVideoEmbedView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import SwiftUI
import WebKit

public struct FilmVideoEmbedView: View {
    public let embedURL: URL?

    public init(embedURL: URL?) {
        self.embedURL = embedURL
    }

    public var body: some View {
        if let url = embedURL {
            WebView(url: url)
        } else {
            ZStack {
                Color.black.opacity(0.4)
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

public struct WebView: UIViewRepresentable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: config)
        view.scrollView.isScrollEnabled = false
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // If your URL is "https://www.youtube.com/embed/...", load directly.
        webView.load(URLRequest(url: url))
    }
}
