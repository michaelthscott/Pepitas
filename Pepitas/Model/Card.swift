//
//  Card.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import SwiftData

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
