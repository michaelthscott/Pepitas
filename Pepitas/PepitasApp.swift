//
//  PepitasApp.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI
import SwiftData

@main
struct PepitasApp: App {
    @State private var deck = Deck()
    @State private var speech = Speech()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(deck)
        .environment(speech)
    }
}
