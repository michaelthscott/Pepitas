//
//  Deck.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftData

@MainActor
@Observable final class Deck {
    let container: ModelContainer
    var cards: [Card] = []
    @ObservationIgnored var index: Array<Card>.Index = 0

    /// Why the stored cards couldn't be opened, when the deck has fallen back to a temporary
    /// in-memory store. Cards added in that state aren't kept after the app quits.
    private(set) var storeError: (any Error)?

    /// - Parameter url: Where to keep the store, instead of the default location. Used by tests.
    init(isStoredInMemoryOnly: Bool = false, url: URL? = nil) {
        let schema = Schema(versionedSchema: PepitasMigrationPlan.currentSchema)
        let modelConfiguration = if let url {
            ModelConfiguration(schema: schema, url: url)
        } else {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        }
        do {
            container = try ModelContainer(for: schema, migrationPlan: PepitasMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            // Rather than crash on every launch, carry on with an empty temporary deck and
            // let the UI explain. The store on disk is left untouched, so nothing is lost.
            print("Could not open the stored cards, using a temporary deck: \(error)")
            storeError = error
            do {
                container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
            } catch {
                fatalError("Could not create an in-memory ModelContainer: \(error)")
            }
        }
        loadStoredCards()
    }

    var isEmpty: Bool { cards.isEmpty }
    
    var topCard: Card? {
        guard !cards.isEmpty else { return nil }
        return cards[index]
    }
    
    func advanceToNextCard() {
        if cards.index(after: index) >= cards.endIndex {
            cards.shuffle()
            index = cards.startIndex
        } else {
            cards.formIndex(after: &index)
        }
    }
    
    func loadStoredCards() {
        let descriptor = FetchDescriptor<Card>(sortBy: [.init(\Card.front)])
        do {
            cards = try container.mainContext.fetch(descriptor)
        } catch {
            print("Failed to load stored cards: \(error.localizedDescription)")
            cards = []
        }
        index = cards.startIndex
    }
    
    /// Saves `card`, adding it to the deck first if it's new.
    func save(_ card: Card) {
        if !cards.contains(card) {
            container.mainContext.insert(card)
        }
        do {
            try container.mainContext.save()
            loadStoredCards()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCard(_ card: Card) {
        container.mainContext.delete(card)
        do {
            try container.mainContext.save()
            loadStoredCards()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCards(at indices: IndexSet) {
        for index in indices {
            container.mainContext.delete(cards[index])
        }
        do {
            try container.mainContext.save()
            loadStoredCards()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func card(for id: Card.ID) -> Card? {
        cards.first(where: { $0.id == id })
    }
}


