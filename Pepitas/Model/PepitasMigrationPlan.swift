//
//  PepitasMigrationPlan.swift
//  Pepitas
//
//  Created by Michael Scott on 29/09/2026.
//

import SwiftData

/// Describes every version of the schema and how to migrate between them.
///
/// To change the model:
/// 1. Add a `SchemaV2` enum containing a copy of `Card` with your changes.
/// 2. Append `SchemaV2.self` to `schemas`.
/// 3. Append a stage to `stages`, for example
///    `.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)` for additive
///    changes, or `.custom(...)` when existing data needs transforming.
/// 4. Point the `Card` typealias and `currentSchema` at `SchemaV2`.
nonisolated enum PepitasMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }

    /// The schema version the app currently uses.
    static var currentSchema: any VersionedSchema.Type { SchemaV1.self }
}
