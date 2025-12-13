//
//  GIFView.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    let name: String
    let bundle: Bundle = .main

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = bundle.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        uiView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "utf-8",
            baseURL: url.deletingLastPathComponent()
        )
    }
}
