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
    let deepL: DeepL
    
    init(deck: Deck, speech: Speech, deepL: DeepL) {
        self.deck = deck
        self.speech = speech
        self.deepL = deepL
    }
}
