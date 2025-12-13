//
//  Extensions+String.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/13/25.
//

import Foundation
import UIKit

extension String {
    /// Decodes common HTML entities (e.g. "&amp;" -> "&") and strips simple HTML if present.
    ///
    /// Useful when API fields are HTML-escaped even though they are displayed as plain text.
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        if let attributed = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) {
            return attributed.string
        }

        // Fallback for very small cases.
        return self
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
