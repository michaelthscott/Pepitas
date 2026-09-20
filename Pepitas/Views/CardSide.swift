//
//  CardSide.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI

struct CardSide: View {
    let text: String
    let isVisible: Bool

    var body: some View {
        Text(text)
            .rotation3DEffect(.degrees(isVisible ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .font(.largeTitle)
            .opacity(isVisible ? 1.0 : 0.0)
    }
}

#Preview("Visible") {
    CardSide(text: "Some text", isVisible: true)
}

#Preview("Not Visible") {
    CardSide(text: "Some text", isVisible: false)
}
