//
//  ArticleParser.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import Foundation
import SwiftUI

enum ArticleBlock: Equatable {
    case paragraph(String)
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

            // 1. Everything BEFORE this [caption] → paragraphs
            let before = String(html[currentIndex..<matchRange.lowerBound])
            appendParagraphs(from: before, into: &blocks)

            // 2. The [caption] content → image block
            if let innerRange = Range(match.range(at: 1), in: html) {
                let captionContent = String(html[innerRange])
                if let imageBlock = parseCaptionBlock(captionContent) {
                    blocks.append(imageBlock)
                }
            }

            currentIndex = matchRange.upperBound
        }

        // 3. Any trailing content AFTER the last [caption]
        let remaining = String(html[currentIndex...])
        appendParagraphs(from: remaining, into: &blocks)

        return blocks
    }

    // MARK: - Helpers

    private static func appendParagraphs(from html: String, into blocks: inout [ArticleBlock]) {
        let pattern = #"<p[^>]*>(.*?)</p>"#
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: [.dotMatchesLineSeparators]
        )

        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: html, options: [], range: range)

        if matches.isEmpty {
            let stripped = html
                .strippingSimpleHTML()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !stripped.isEmpty {
                blocks.append(.paragraph(stripped))
            }
            return
        }

        for m in matches {
            guard let r = Range(m.range(at: 1), in: html) else { continue }
            let inner = String(html[r])

            let stripped = inner
                .strippingSimpleHTML()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !stripped.isEmpty {
                blocks.append(.paragraph(stripped))
            }
        }
    }

    private static func parseCaptionBlock(_ html: String) -> ArticleBlock? {
        // Extract img src
        let imgPattern = #"<img[^>]*src=\"([^\"]+)\"[^>]*>"#
        let regex = try! NSRegularExpression(pattern: imgPattern, options: [])
        let ns = html as NSString
        let range = NSRange(location: 0, length: ns.length)

        guard let m = regex.firstMatch(in: html, options: [], range: range),
              let srcRange = Range(m.range(at: 1), in: html) else {
            return nil
        }

        let src = String(html[srcRange])

        // Caption text = caption content with the <img> tag removed
        guard let imgTagRange = Range(m.range, in: html) else { return nil }
        var captionHtml = html
        captionHtml.removeSubrange(imgTagRange)

        let caption = captionHtml
            .strippingSimpleHTML()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: src) else { return nil }

        return .image(url, caption.isEmpty ? nil : caption)
    }
}

// Very lightweight HTML stripper; good enough for these blocks.
private extension String {
    func strippingSimpleHTML() -> String {
        var s = self

        // Replace explicit line breaks with newline to keep separation.
        s = s.replacingOccurrences(of: "(?i)<br\\s*/?>", with: "\n", options: .regularExpression)

        // Remove remaining tags.
        s = s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // Decode common HTML entities that affect wrapping/readability.
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
            // Soft hyphen: encourage wrapping opportunities.
            .replacingOccurrences(of: "&shy;", with: "\u{00AD}")

        // Collapse runs of whitespace/newlines to a single space (but keep newlines).
        // First normalize CRLF to LF
        s = s.replacingOccurrences(of: "\r\n", with: "\n")
        s = s.replacingOccurrences(of: "\r", with: "\n")
        // Replace multiple spaces with single
        s = s.replacingOccurrences(of: "[ \\t]{2,}", with: " ", options: .regularExpression)
        // Trim spaces around newlines
        s = s.replacingOccurrences(of: " *\n *", with: "\n", options: .regularExpression)

        return s
    }
}
