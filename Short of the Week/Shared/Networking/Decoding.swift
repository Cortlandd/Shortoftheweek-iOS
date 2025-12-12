//
//  Decoding.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

import Foundation

public enum DecodeDebug {
    public static func describe(_ error: Error) -> String {
        guard let error = error as? DecodingError else { return "\(error)" }

        switch error {
        case let .typeMismatch(type, context):
            return "typeMismatch(\(type)) @ \(codingPath(context)): \(context.debugDescription)"
        case let .valueNotFound(type, context):
            return "valueNotFound(\(type)) @ \(codingPath(context)): \(context.debugDescription)"
        case let .keyNotFound(key, context):
            return "keyNotFound(\(key.stringValue)) @ \(codingPath(context)): \(context.debugDescription)"
        case let .dataCorrupted(context):
            return "dataCorrupted @ \(codingPath(context)): \(context.debugDescription)"
        @unknown default:
            return "unknown decoding error: \(error)"
        }
    }

    private static func codingPath(_ context: DecodingError.Context) -> String {
        context.codingPath.map(\.stringValue).joined(separator: ".")
    }
}
