//
//  ViewDisplayMode.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/12/25.
//

enum ViewDisplayMode<Content: Equatable>: Equatable {
    case loading
    case content
    case empty(message: String)
    case error(message: String)
}
