//
//  Card.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftData

/// The current version of the card model. Update this when adding a new schema version.
typealias Card = SchemaV1.Card

/// The original schema, as shipped in the first TestFlight build.
///
/// Don't change this model: existing stores were created with it, and the migration
/// plan relies on it to open them. To change the model, add a `SchemaV2` with a copy
/// of `Card`, then add a stage to `PepitasMigrationPlan`.
nonisolated enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Card.self] }

    @Model
    final class Card: Identifiable, Hashable {
        @Attribute var id: UUID = UUID()
        @Attribute var front: String = ""
        @Attribute var back: String = ""

        init(front: String = "", back: String = "") {
            self.front = front
            self.back = back
        }
    }
}

extension Card: Comparable {
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.front < rhs.front
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        "'\(front)'"
    }
}
