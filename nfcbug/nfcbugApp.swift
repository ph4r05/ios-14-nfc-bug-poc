//
//  nfcbugApp.swift
//  nfcbug
//
//  Created by Dusan Klinec on 30/09/2020.
//

import SwiftUI

@main
struct nfcbugApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
