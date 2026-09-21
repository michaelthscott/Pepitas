//
//  SettingsView.swift
//  Pepitas
//
//  Created by Michael Scott on 21/09/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(DeepL.self) private var deepL
    @State private var authKey = ""

    /// The key as it will be stored, ignoring whitespace picked up while pasting.
    private var trimmedAuthKey: String {
        authKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API key", text: $authKey, prompt: Text("DeepL API key"))
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit(save)
                    LabeledContent("Stored key") {
                        Text(deepL.isConfigured ? "Saved" : "None")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("DeepL")
                } footer: {
                    Text("Used to translate the front of a card into Portuguese. Create a free key at deepl.com; free keys end in \":fx\". The key is kept in the keychain and isn't shown again once saved.")
                }

                Section {
                    Button("Save", action: save)
                        .disabled(trimmedAuthKey.isEmpty)
                    Button("Remove key", role: .destructive) {
                        deepL.authKey = ""
                    }
                    .disabled(!deepL.isConfigured)
                }
            }
            .navigationTitle("Settings")
        }
    }

    /// Stores the key and clears the field, so the saved key is never left on screen.
    private func save() {
        deepL.authKey = trimmedAuthKey
        authKey = ""
    }
}

#Preview(traits: .modifier(EmptyDeck())) {
    SettingsView()
}
