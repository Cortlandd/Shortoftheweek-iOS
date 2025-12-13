//
//  ShortoftheWeekApp.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct ShortoftheWeekApp: App {

    init() {
        // A reasonably-sized shared URLCache helps prevent image/network thrash when
        // scrolling the feed or revisiting detail screens.
        // NOTE: This impacts all URLSession requests that use URLCache.shared.
        let memoryCapacity = 64 * 1024 * 1024   // 64 MB
        let diskCapacity = 256 * 1024 * 1024    // 256 MB
        URLCache.shared = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: RootReducer.State()) {
                    RootReducer()
                }
            )
        }
    }
}
