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
}

struct ContentView: View {
    @Environment(Deck.self) private var deck
    @State private var clicked: Bool = false
    @State private var showFront: Bool = true
    @State private var selectedTab: Tabs = .deck

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Card", systemImage: "square", value: Tabs.card) {
                NextCardView()
                    .frame(height:200.0)
                    .padding()
            }
            Tab("Deck", systemImage: "square.stack", value: Tabs.deck) {
                DeckSplitView()
            }
        }
    }
}

#Preview("Sample deck", traits: .modifier(SampleDeck())) {
    ContentView()
}

#Preview("Empty deck", traits: .modifier(EmptyDeck())) {
    ContentView()
}
