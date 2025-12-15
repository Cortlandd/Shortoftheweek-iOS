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
        if let url = embedURL,
           let embed = VideoEmbed.from(url: url) {
            VideoEmbedWebView(embed: embed)
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

// MARK: - VideoEmbed model

private struct VideoEmbed: Equatable {
    enum Provider: Equatable {
        case youtubeVideo(id: String)
        case vimeo(id: String)
    }

    let provider: Provider

    var baseURL: URL {
        switch provider {
        case .youtubeVideo:
            return URL(string: "https://www.youtube-nocookie.com")!
        case .vimeo:
            return URL(string: "https://player.vimeo.com")!
        }
    }

    var iframeSrc: String {
        switch provider {
        case .youtubeVideo(let id):
            let clean = VideoEmbed.sanitizeID(id)
            // rel=0 reduces “related” to same channel, but doesn’t remove end-cards completely.
            return "https://www.youtube-nocookie.com/embed/\(clean)?playsinline=1&modestbranding=1&rel=0&fs=1&controls=1&disablekb=1&enablejsapi=1&origin=https://www.youtube-nocookie.com"

        case .vimeo(let id):
            let clean = VideoEmbed.sanitizeID(id)
            return "https://player.vimeo.com/video/\(clean)?autoplay=1&title=0&byline=0&portrait=0"
        }
    }

    var html: String {
        """
        <html>
        <head>
            <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
            <style>
                html, body { margin:0; padding:0; height:100%; background:black; overflow:hidden; }
                iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:0; }
            </style>
        </head>
        <body>
            <iframe
                src="\(iframeSrc)"
                frameborder="0"
                allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """
    }

    static func from(url: URL) -> VideoEmbed? {
        if let ytID = YouTubeExtractor.extractVideoID(from: url) {
            return VideoEmbed(provider: .youtubeVideo(id: ytID))
        }
        if let vimeoID = VimeoExtractor.extract(from: url) {
            return VideoEmbed(provider: .vimeo(id: vimeoID))
        }
        return nil
    }

    private static func sanitizeID(_ raw: String) -> String {
        raw.components(separatedBy: ["?", "&"]).first ?? raw
    }
}


// MARK: - WebView wrapper

private struct VideoEmbedWebView: UIViewRepresentable {
    let embed: VideoEmbed

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        if #available(iOS 14.0, *) {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            config.defaultWebpagePreferences = prefs
        } else {
            config.preferences.javaScriptEnabled = true
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        webView.navigationDelegate = context.coordinator
        context.coordinator.setExpected(embed: embed)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.setExpected(embed: embed)

        if context.coordinator.lastHTML == embed.html { return }
        context.coordinator.lastHTML = embed.html

        webView.loadHTMLString(embed.html, baseURL: embed.baseURL)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String?
        private var expectedYouTubeID: String?
        private var expectedVimeoID: String?

        func setExpected(embed: VideoEmbed) {
            switch embed.provider {
            case .youtubeVideo(let id):
                expectedYouTubeID = id
                expectedVimeoID = nil
            case .vimeo(let id):
                expectedVimeoID = id
                expectedYouTubeID = nil
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            // Allow the initial loads + internal about:blank
            if url.absoluteString == "about:blank" {
                decisionHandler(.allow)
                return
            }

            // YouTube: only allow staying on the SAME embed/<id>
            if let expectedYouTubeID {
                let host = (url.host ?? "").lowercased()

                if host.contains("youtube") {
                    let path = url.path.lowercased()
                    // Allow only /embed/<same-id> and other harmless internal resources.
                    if path.contains("/embed/") {
                        // if it’s trying to switch to a different embed, block it
                        if !path.contains("/embed/\(expectedYouTubeID.lowercased())") {
                            decisionHandler(.cancel)
                            return
                        }
                    } else if path.contains("/watch") || path.contains("/shorts") || path.contains("/playlist") {
                        decisionHandler(.cancel)
                        return
                    }

                    decisionHandler(.allow)
                    return
                }

                // Block external navigations caused by taps
                decisionHandler(.cancel)
                return
            }

            // Vimeo: optionally do the same “lock” behavior
            if let expectedVimeoID {
                let host = (url.host ?? "").lowercased()
                if host.contains("vimeo.com") {
                    // allow only player.vimeo.com/video/<id>
                    if url.path.contains("/video/") && url.absoluteString.contains(expectedVimeoID) {
                        decisionHandler(.allow)
                        return
                    }
                    decisionHandler(.cancel)
                    return
                }
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.cancel)
        }
    }
}


// MARK: - Extractors

private enum YouTubeExtractor {
    static func extractVideoID(from url: URL) -> String? {
        let host = (url.host ?? "").lowercased()
        let path = url.path
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = comps?.queryItems ?? []

        func q(_ name: String) -> String? {
            queryItems.first(where: { $0.name == name })?.value
        }

        // youtu.be/<id>
        if host == "youtu.be" {
            let id = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return id.isEmpty ? nil : sanitizeID(id)
        }

        // youtube.com / youtube-nocookie.com variants
        if host.contains("youtube.com") || host.contains("youtube-nocookie.com") {
            let cleanedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

            // watch?v=<id>
            if cleanedPath == "watch", let v = q("v"), !v.isEmpty {
                return sanitizeID(v)
            }

            // /embed/<id>
            if cleanedPath.hasPrefix("embed/") {
                let id = String(cleanedPath.dropFirst("embed/".count))
                return id.isEmpty ? nil : sanitizeID(id)
            }

            // /shorts/<id>
            if cleanedPath.hasPrefix("shorts/") {
                let id = String(cleanedPath.dropFirst("shorts/".count))
                return id.isEmpty ? nil : sanitizeID(id)
            }
        }

        return nil
    }

    private static func sanitizeID(_ raw: String) -> String {
        raw.components(separatedBy: ["?", "&"]).first ?? raw
    }
}

private enum VimeoExtractor {
    static func extract(from url: URL) -> String? {
        let host = (url.host ?? "").lowercased()
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        // vimeo.com/<id>
        if host == "vimeo.com" {
            return firstNumericComponent(in: path)
        }

        // player.vimeo.com/video/<id>
        if host == "player.vimeo.com", path.hasPrefix("video/") {
            return firstNumericComponent(in: String(path.dropFirst("video/".count)))
        }

        return nil
    }

    private static func firstNumericComponent(in s: String) -> String? {
        let first = s.split(separator: "/").first.map(String.init)
        guard let first, !first.isEmpty else { return nil }
        return first.allSatisfy(\.isNumber) ? first : nil
    }
}
