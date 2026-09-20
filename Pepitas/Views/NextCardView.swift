//
//  NextCardView.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI

struct NextCardView: View {
    @Environment(Deck.self) private var deck
    @Environment(Speech.self) private var speech
    @State private var showFront: Bool = true

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showFront.toggle()
                    if showFront {
                        deck.advanceToNextCard()
                    } else {
                        speech.speak(deck.topCard?.back ?? "Sem cartão")
                    }
                }
            }, label: {
                ZStack {
                    CardSide(text: deck.topCard?.front ?? "No card", isVisible: showFront)
                    CardSide(text: deck.topCard?.back ?? "Sem cartão", isVisible: !showFront)
                }
            })
            .disabled(deck.isAlmostEmpty)
        }
    }
}

#Preview("Sample deck", traits: .modifier(SampleDeck())) {
    NextCardView()
}

#Preview("Empty deck", traits: .modifier(EmptyDeck())) {
    NextCardView()
}
