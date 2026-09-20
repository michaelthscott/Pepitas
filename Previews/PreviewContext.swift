//
//  PreviewContext.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation

struct PreviewContext {
    let deck: Deck
    let speech: Speech
    
    init(deck: Deck, speech: Speech) {
        self.deck = deck
        self.speech = speech
    }
}
