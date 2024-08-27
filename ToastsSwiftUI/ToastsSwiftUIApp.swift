//
//  ToastsSwiftUIApp.swift
//  ToastsSwiftUI
//
//  Created by Rashid Latif on 27/08/2024.
//

import SwiftUI

@main
struct ToastsSwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
