//
//  CardEditor.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import SwiftUI

struct CardEditor: View {
    enum FocusedField {
        case front, back
    }

    @Environment(Deck.self) private var deck
    @Environment(DeepL.self) private var deepL
    @Environment(\.dismiss) private var dismiss
    var card: Card
    @State private var front = ""
    @State private var back = ""
    @State private var translation: Task<Void, Never>?
    @State private var isTranslating = false
    @State private var translationError: String?
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        Form {
            Section(header: Text("Front")) {
                TextField("Front", text: $front, prompt: Text("English"), axis: .vertical)
                    .focused($focusedField, equals: .front)
                    .submitLabel(.next)
                    .onSubmit(submitFront)
                    .onChange(of: front) { _, newValue in
                        // The front is a single line, so any newline (typed or pasted) is a submit.
                        let singleLine = newValue.filter { !$0.isNewline }
                        guard singleLine != newValue else { return }
                        front = singleLine
                        submitFront()
                    }
            }
            Section(header: Text("Back")) {
                TextField("Back", text: $back, prompt: Text("Portuguese"), axis: .vertical)
                    .focused($focusedField, equals: .back)
                    .submitLabel(.done)
                    .onSubmit(submitBack)
                    .onChange(of: back) { _, newValue in
                        // The back is a single line, so any newline (typed or pasted) is a submit.
                        let singleLine = newValue.filter { !$0.isNewline }
                        guard singleLine != newValue else { return }
                        back = singleLine
                        submitBack()
                    }
                if isTranslating {
                    HStack {
                        ProgressView()
                        Text("Translating…")
                            .foregroundStyle(.secondary)
                    }
                }
                if let translationError {
                    Text(translationError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            front = card.front
            back = card.back
            focusedField = .front
        }
        .onDisappear {
            translation?.cancel()
        }
    }

    /// Moves on to the back of the card and translates the front.
    private func submitFront() {
        focusedField = .back
        translate()
    }

    /// Saves the card and closes the editor.
    private func submitBack() {
        card.front = front
        card.back = back
        deck.addCardIfNew(card)
        dismiss()
    }

    /// Fills in the back of the card with a Portuguese translation of the front.
    private func translate() {
        let english = front.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !english.isEmpty else { return }

        translation?.cancel()
        translationError = nil
        translation = Task {
            isTranslating = true
            defer { isTranslating = false }
            do {
                let portuguese = try await deepL.portuguese(for: english)
                guard !Task.isCancelled else { return }
                back = portuguese
            } catch {
                // A cancelled request has been superseded by a newer one, so stay quiet.
                guard !Task.isCancelled else { return }
                translationError = error.localizedDescription
            }
        }
    }
}

#Preview("Existing card", traits: .modifier(SampleDeck())) {
    @Previewable @Environment(Deck.self) var deck
    NavigationStack {
        List(deck.cards) { card in
            NavigationLink(card.front) {
                CardEditor(card: card)
            }
        }
    }
}

#Preview("New card", traits: .modifier(EmptyDeck())) {
    @Previewable @Environment(Deck.self) var deck
    @Previewable @State var newCard: Card = Card()
    NavigationStack {
        List([newCard]) { card in
            NavigationLink(card.front) {
                CardEditor(card: card)
            }
        }
    }
}
