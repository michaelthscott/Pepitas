//
//  JSONCard.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation

final class JSONCard {
    var front: String
    var back: String

    init(front: String = "", back: String = "") {
        self.front = front
        self.back = back
    }
}
extension JSONCard: Codable {
    enum CodingKeys: String, CodingKey {
        case front
        case back
    }
    
    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let front = try container.decode(String.self, forKey: .front)
        let back = try container.decode(String.self, forKey: .back)
        self.init(front: front, back: back)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(front, forKey: .front)
        try container.encode(back, forKey: .back)
    }
}
