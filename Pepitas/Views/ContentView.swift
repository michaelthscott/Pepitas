//
//  ContentView.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI
import SwiftData

enum Tabs: Hashable {
    case card
    case deck
    case settings
}

struct ContentView: View {
    @Environment(Deck.self) private var deck
    @State private var clicked: Bool = false
    @State private var showFront: Bool = true
    @State private var selectedTab: Tabs = .deck
    @State private var isShowingStoreError = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Card", systemImage: "square", value: Tabs.card) {
                NextCardView()
            }
            Tab("Deck", systemImage: "square.stack", value: Tabs.deck) {
                DeckSplitView()
            }
            Tab("Settings", systemImage: "gear", value: Tabs.settings) {
                SettingsView()
            }
        }
        .onAppear {
            isShowingStoreError = deck.storeError != nil
        }
        .alert("Your cards couldn't be opened", isPresented: $isShowingStoreError) {
            Button("OK") {}
        } message: {
            Text("Pepitas is using a temporary deck for now, and cards you add to it won't be kept. Your saved cards haven't been deleted. Try quitting and reopening the app.")
        }
    }
}

#Preview("Sample deck", traits: .modifier(SampleDeck())) {
    ContentView()
}

#Preview("Empty deck", traits: .modifier(EmptyDeck())) {
    ContentView()
}
