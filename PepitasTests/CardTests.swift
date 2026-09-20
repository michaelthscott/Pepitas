//
//  CardTests.swift
//  PepitasTests
//
//  Created by Michael Scott on 20/09/2026.
//

import Testing
@testable import Pepitas
import SwiftData
import Foundation

struct CardTests {
    
    @MainActor @Test func testCard() async throws {
        let schema = Schema([Card.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let card = Card(front: "Hello", back: "Olá")
        #expect(card.id.uuidString.count == 36)
        #expect(card.front == "Hello")
        #expect(card.back == "Olá")
        container.mainContext.insert(card)
        #expect(try container.mainContext.fetch(FetchDescriptor<Card>()).count == 1)
    }

}
