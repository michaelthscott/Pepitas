//
//  CardEditor.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI

struct CardEditor: View {
    enum FocusedField {
        case front, back
    }

    @Environment(Deck.self) private var deck
    @Environment(\.dismiss) private var dismiss
    var card: Card
    @State private var front = ""
    @State private var back = ""
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        Form {
            Section(header: Text("Front")) {
                TextField("Front", text: $front, prompt: Text("English"))
                    .focused($focusedField, equals: .front)
                    .onSubmit {
                        focusedField = .back
//                        Task {
//                            back = try await DeepL().portuguese(for: front)
//                        }
                    }
            }
            Section(header: Text("Back")) {
                TextField("Back", text: $back, prompt: Text("Portuguese"))
                    .focused($focusedField, equals: .back)
                    .onSubmit {
                        card.front = front
                        card.back = back
                        deck.addCardIfNew(card)
                        dismiss()
                    }
            }
        }
        .onAppear {
            front = card.front
            back = card.back
            focusedField = .front
        }
    }
}

#Preview("Existing card", traits: .modifier(SampleDeck())) {
    @Previewable @Environment(Deck.self) var deck
    NavigationStack {
        List(deck.cards) { card in
            NavigationLink(card.front) {
                CardEditor(card: card)
            }
        }
    }
}

#Preview("New card", traits: .modifier(EmptyDeck())) {
    @Previewable @Environment(Deck.self) var deck
    @Previewable @State var newCard: Card = Card()
    NavigationStack {
        List([newCard]) { card in
            NavigationLink(card.front) {
                CardEditor(card: card)
            }
        }
    }
}

