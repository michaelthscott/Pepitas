//
//  SampleDeck.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftUI
import SwiftData

struct SampleDeck: PreviewModifier {
    typealias Context = PreviewContext

    static func makeSharedContext() async throws -> Context {
        let assetName = "PreviewData"
        guard let asset = NSDataAsset(name: assetName) else {
            fatalError("Failed to load \(assetName)")
        }
        guard let jsonDeck = try? JSONDecoder().decode(JSONDeck.self, from: asset.data) else {
            fatalError("Failed to decode \(assetName)")
        }
        let deck = Deck(isStoredInMemoryOnly: true)
        for jsonCard in jsonDeck.cards {
            deck.container.mainContext.insert(Card(front: jsonCard.front, back: jsonCard.back))
        }
        deck.loadStoredCards()
        return PreviewContext(deck: deck, speech: Speech(), deepL: DeepL())
    }
    
    func body(content: Content, context: Context) -> some View {
        content
            .environment(context.deck)
            .environment(context.speech)
            .environment(context.deepL)
    }
}
