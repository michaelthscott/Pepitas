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

    /// A store that can't be opened must not crash the app. The deck falls back to an
    /// empty temporary store, reports the error, and leaves the file on disk alone.
    @MainActor @Test func unreadableStoreFallsBackToTemporaryDeck() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "default.store")
        let garbage = Data("This is not a SQLite database.".utf8)
        try garbage.write(to: url)

        let deck = Deck(url: url)
        #expect(deck.storeError != nil)
        #expect(deck.isEmpty)

        deck.save(Card(front: "Hello", back: "Olá"))
        #expect(deck.cards.count == 1)
        #expect(try Data(contentsOf: url) == garbage)
    }

    @MainActor @Test func defaultDeckHasNoStoreError() {
        let deck = Deck(isStoredInMemoryOnly: true)
        #expect(deck.storeError == nil)
    }

}
