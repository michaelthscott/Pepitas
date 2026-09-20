//
//  DeckSplitView.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI

struct DeckSplitView: View {
    @Environment(Deck.self) private var deck
    @State private var selection: Card.ID?
    @State private var createNewCard: Bool = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(deck.cards) { card in
                    NavigationLink(card.front, value: card.id)
                }
                .onDelete { indexSet in
                    deck.deleteCards(at: indexSet)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        createNewCard = true
                    } label: {
                        Label("Add card", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    EditButton()
                }
            }
        } detail: {
            if let id = selection,
               let card = deck.card(for: id) {
                CardEditor(card: card)
                    .id(id)
            } else {
                ContentUnavailableView {
                    Label("No selection", systemImage: "magnifyingglass")
                } description: {
                    Text("Select a card to edit.")
                }
            }
        }
        .sheet(isPresented: $createNewCard) {
            CardEditor(card: Card())
        }
    }
}

#Preview("Sample deck", traits: .modifier(SampleDeck())) {
    DeckSplitView()
}

#Preview("Empty deck", traits: .modifier(EmptyDeck())) {
    DeckSplitView()
}
