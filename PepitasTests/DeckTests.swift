//
//  DeckTests.swift
//  PepitasTests
//
//  Created by Michael Scott on 20/09/2026.
//

import Testing
@testable import Pepitas
import UIKit
import SwiftData

struct DeckTests {
    
    @MainActor @Test func testDeck() async throws {
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
        #expect(deck.cards.count == jsonDeck.cards.count)
    }

}
