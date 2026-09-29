//
//  MigrationTests.swift
//  PepitasTests
//
//  Created by Michael Scott on 29/09/2026.
//

import Testing
@testable import Pepitas
import SwiftData
import Foundation

struct MigrationTests {

    /// Nesting `Card` inside `SchemaV1` must not change its stored entity name,
    /// or stores created before versioning would no longer match.
    @Test func entityNameIsUnchanged() {
        let schema = Schema(versionedSchema: SchemaV1.self)
        #expect(schema.entities.map(\.name) == ["Card"])
    }

    /// A store created without a migration plan, as the first TestFlight build did,
    /// must open with the migration plan and keep its cards.
    @MainActor @Test func unversionedStoreOpensWithMigrationPlan() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "default.store")

        // Create the store the way the app did before versioning.
        do {
            let schema = Schema([Card.self])
            let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: url)])
            container.mainContext.insert(Card(front: "Hello", back: "Olá"))
            try container.mainContext.save()
        }

        // Reopen it the way the app does now.
        let schema = Schema(versionedSchema: PepitasMigrationPlan.currentSchema)
        let container = try ModelContainer(for: schema, migrationPlan: PepitasMigrationPlan.self, configurations: [ModelConfiguration(schema: schema, url: url)])
        let cards = try container.mainContext.fetch(FetchDescriptor<Card>())
        #expect(cards.map(\.front) == ["Hello"])
        #expect(cards.map(\.back) == ["Olá"])
    }

}
