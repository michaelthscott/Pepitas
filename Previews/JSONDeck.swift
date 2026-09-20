//
//  JSONDeck.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftData

final class JSONDeck {
    let cards: [JSONCard]
    
    init(cards: [JSONCard] = []) {
        self.cards = cards
    }
}

extension JSONDeck: Codable {
    enum CodingKeys: String, CodingKey {
        case cards
    }
    
    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cards = try container.decode([JSONCard].self, forKey: .cards)
        self.init(cards: cards)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
    }
}
