//
//  Short_of_the_WeekApp.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import SwiftUI
import CoreData

@main
struct Short_of_the_WeekApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
