//
//  EmptyDeck.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftUI

struct EmptyDeck: PreviewModifier {
    typealias Context = PreviewContext
    
    static func makeSharedContext() async throws -> Context {
        PreviewContext(deck: Deck(isStoredInMemoryOnly: true), speech: Speech(), deepL: DeepL())
    }
    
    func body(content: Content, context: Context) -> some View {
        content
            .environment(context.deck)
            .environment(context.speech)
            .environment(context.deepL)
    }
}
