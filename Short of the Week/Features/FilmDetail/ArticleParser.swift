//
//  ArticleParser.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//
import Foundation
import SwiftUI

enum ArticleBlock: Equatable {
    case heading(level: Int, String)
    case paragraph(String)
    case bulletedList([String])
    case image(URL, String?)
}

struct ArticleParser {

    static func parse(_ html: String) -> [ArticleBlock] {
        var blocks: [ArticleBlock] = []

        let captionPattern = #"\[caption[^\]]*\](.*?)\[/caption\]"#
        let captionRegex = try! NSRegularExpression(
            pattern: captionPattern,
            options: [.dotMatchesLineSeparators]
        )

        let nsHtml = html as NSString
        let fullRange = NSRange(location: 0, length: nsHtml.length)
        let matches = captionRegex.matches(in: html, options: [], range: fullRange)

        var currentIndex = html.startIndex

        for match in matches {
            guard let matchRange = Range(match.range, in: html) else { continue }

            // 1) Content BEFORE caption → parse blocks in-order (headings, paragraphs, lists, stray text)
            let before = String(html[currentIndex..<matchRange.lowerBound])
            appendBlocks(from: before, into: &blocks)

            // 2) Caption content → image block
            if let innerRange = Range(match.range(at: 1), in: html) {
                let captionContent = String(html[innerRange])
                if let imageBlock = parseCaptionBlock(captionContent) {
                    blocks.append(imageBlock)
                }
            }

            currentIndex = matchRange.upperBound
        }

        // 3) Trailing content AFTER last caption
        let remaining = String(html[currentIndex...])
        appendBlocks(from: remaining, into: &blocks)

        return blocks
    }

    // MARK: - Helpers

    private static func appendBlocks(from html: String, into blocks: inout [ArticleBlock]) {
        // Capture <h1..h6>, <p>, <ul>, <ol> in document order
        let pattern = #"<(h[1-6]|p|ul|ol|figure)[^>]*>(.*?)</\1>"#
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        )

        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: html, options: [], range: range)

        // If no recognizable blocks, treat whatever’s left as a paragraph.
        guard !matches.isEmpty else {
            appendLooseTextAsParagraph(html, into: &blocks)
            return
        }

        var cursor = html.startIndex

        for m in matches {
            guard
                let wholeRange = Range(m.range, in: html),
                let tagRange = Range(m.range(at: 1), in: html),
                let innerRange = Range(m.range(at: 2), in: html)
            else { continue }

            // Anything between previous match and this match:
            let between = String(html[cursor..<wholeRange.lowerBound])
            appendLooseTextAsParagraph(between, into: &blocks)

            let tag = String(html[tagRange]).lowercased()
            let inner = String(html[innerRange])

            switch tag {
            case let t where t.hasPrefix("h"):
                let level = Int(t.dropFirst()) ?? 2
                let text = inner.strippingSimpleHTML().trimmedNonEmpty
                if let text { blocks.append(.heading(level: level, text)) }

            case "p":
                let text = inner.strippingSimpleHTML().trimmedNonEmpty
                if let text { blocks.append(.paragraph(text)) }

            case "ul", "ol":
                let items = parseListItems(inner)
                if !items.isEmpty { blocks.append(.bulletedList(items)) }

            case "figure":
                if let image = parseFigureBlock(inner) {
                    blocks.append(image)
                }

            default:
                break
            }

            cursor = wholeRange.upperBound
        }

        // Trailing loose text after the last match:
        let tail = String(html[cursor...])
        appendLooseTextAsParagraph(tail, into: &blocks)
    }

    private static func parseListItems(_ html: String) -> [String] {
        let pattern = #"<li[^>]*>(.*?)</li>"#
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        )
        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)

        return regex.matches(in: html, options: [], range: range).compactMap { m in
            guard let r = Range(m.range(at: 1), in: html) else { return nil }
            return String(html[r]).strippingSimpleHTML().trimmedNonEmpty
        }
    }
    
    private static func extractImgSrc(from imgTag: String) -> URL? {
        // src="..."
        let srcRegex = try! NSRegularExpression(
            pattern: #"\bsrc\s*=\s*(['"])(.*?)\1"#,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        )

        let ns = imgTag as NSString
        let range = NSRange(location: 0, length: ns.length)

        guard let m = srcRegex.firstMatch(in: imgTag, options: [], range: range) else { return nil }
        guard let r = Range(m.range(at: 2), in: imgTag) else { return nil }
        
        print("LOOSE IMG:", imgTag)

        let raw = String(imgTag[r])
        return URL(string: raw)
    }

    private static func appendLooseTextAsParagraph(_ html: String, into blocks: inout [ArticleBlock]) {
        // If loose chunks contain <img ...> (common in div/a wrappers), emit image blocks in-order.
        let imgTagPattern = #"<img\b[^>]*>"#
        let imgRegex = try! NSRegularExpression(
            pattern: imgTagPattern,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        )

        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = imgRegex.matches(in: html, options: [], range: range)

        guard !matches.isEmpty else {
            let stripped = html.strippingSimpleHTML().trimmedNonEmpty
            if let stripped { blocks.append(.paragraph(stripped)) }
            return
        }

        var cursor = html.startIndex

        for m in matches {
            guard let imgRange = Range(m.range, in: html) else { continue }

            // 1) Text before the image
            let before = String(html[cursor..<imgRange.lowerBound])
            let beforeText = before.strippingSimpleHTML().trimmedNonEmpty
            if let beforeText { blocks.append(.paragraph(beforeText)) }

            // 2) The image itself
            let imgTag = String(html[imgRange])
            if let url = extractImgSrc(from: imgTag) {
                blocks.append(.image(url, nil))
            }

            cursor = imgRange.upperBound
        }

        // 3) Text after the last image
        let tail = String(html[cursor...])
        let tailText = tail.strippingSimpleHTML().trimmedNonEmpty
        if let tailText { blocks.append(.paragraph(tailText)) }
    }


    private static func parseCaptionBlock(_ html: String) -> ArticleBlock? {
        let imgPattern = #"<img[^>]*src=\"([^\"]+)\"[^>]*>"#
        let regex = try! NSRegularExpression(pattern: imgPattern, options: [.caseInsensitive])
        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)

        guard let m = regex.firstMatch(in: html, options: [], range: range),
              let srcRange = Range(m.range(at: 1), in: html),
              let imgTagRange = Range(m.range, in: html)
        else { return nil }

        let src = String(html[srcRange])

        var captionHtml = html
        captionHtml.removeSubrange(imgTagRange)

        let caption = captionHtml
            .strippingSimpleHTML()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: src) else { return nil }
        return .image(url, caption.isEmpty ? nil : caption)
    }
    
    private static func parseFigureBlock(_ html: String) -> ArticleBlock? {
        // Try to find an <img ...> inside the figure
        guard let url = parseImageURL(from: html) else { return nil }

        // Caption often lives in <figcaption>...</figcaption>
        let captionPattern = #"<figcaption[^>]*>(.*?)</figcaption>"#
        let capRegex = try! NSRegularExpression(pattern: captionPattern, options: [.dotMatchesLineSeparators, .caseInsensitive])
        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)

        var captionText: String? = nil
        if let m = capRegex.firstMatch(in: html, options: [], range: range),
           let r = Range(m.range(at: 1), in: html) {
            captionText = String(html[r]).strippingSimpleHTML().trimmedNonEmpty
        }

        return .image(url, captionText)
    }

    // Handles src="...", data-src="...", data-lazy-src="...", and srcset
    private static func parseImageURL(from html: String) -> URL? {
        func firstAttr(_ name: String) -> String? {
            // matches name="..." or name='...'
            let pattern = #"\b\#(name)\s*=\s*(['"])(.*?)\2"#
            let regex = try! NSRegularExpression(
                pattern: pattern,
                options: [.dotMatchesLineSeparators, .caseInsensitive]
            )

            let ns = html as NSString
            let range = NSRange(location: 0, length: ns.length)

            guard let m = regex.firstMatch(in: html, options: [], range: range) else { return nil }
            
            guard m.numberOfRanges > 2 else { return nil }

            // Group 2 = the attribute value
            guard let r = Range(m.range(at: 2), in: html) else { return nil }
            return String(html[r])
        }

        // Prefer real src; fall back to common lazy-load attrs
        let raw =
            firstAttr("src")
            ?? firstAttr("data-src")
            ?? firstAttr("data-lazy-src")
            ?? firstAttr("data-original")

        if let raw, let url = URL(string: raw) {
            return normalize(url)
        }

        // Fall back to srcset / data-srcset / data-lazy-srcset: take first URL
        let srcset =
            firstAttr("srcset")
            ?? firstAttr("data-srcset")
            ?? firstAttr("data-lazy-srcset")

        if let srcset {
            // "https://... 1200w, https://... 600w" -> take first URL token
            let first = srcset
                .split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
                .first?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                .first
            if let first, let url = URL(string: String(first)) {
                return normalize(url)
            }
        }

        return nil
    }

    private static func normalize(_ url: URL) -> URL? {
        // Some sites return //cdn... URLs
        if url.scheme == nil, url.absoluteString.hasPrefix("//") {
            return URL(string: "https:" + url.absoluteString)
        }
        return url
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let s = trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }

    func strippingSimpleHTML() -> String {
        var s = self

        s = s.replacingOccurrences(of: "(?i)<br\\s*/?>", with: "\n", options: .regularExpression)
        s = s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        s = s
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{202F}", with: " ")
            .replacingOccurrences(of: "\u{2007}", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&ndash;", with: "–")
            .replacingOccurrences(of: "&mdash;", with: "—")
            .replacingOccurrences(of: "&shy;", with: "\u{00AD}")

        s = s.replacingOccurrences(of: "\r\n", with: "\n")
        s = s.replacingOccurrences(of: "\r", with: "\n")
        s = s.replacingOccurrences(of: "[ \\t]{2,}", with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: " *\n *", with: "\n", options: .regularExpression)

        return s
    }
}
