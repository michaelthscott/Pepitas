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
    
    init(isStoredInMemoryOnly: Bool = false) {
        let schema = Schema([
            Card.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly) //, cloudKitDatabase: .private("iCloud.org.michaelthscott.Pepitas"))
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            loadStoredCards()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
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
    
    func addCardIfNew(_ card: Card) {
        guard !cards.contains(card) else { return }
        container.mainContext.insert(card)
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


