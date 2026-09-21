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

    /// The key as it will be stored, so that stray whitespace doesn't count as a change.
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
                } header: {
                    Text("DeepL")
                } footer: {
                    Text("Used to translate the front of a card into Portuguese. Create a free key at deepl.com; free keys end in \":fx\". The key is kept in the keychain.")
                }

                Section {
                    Button("Save", action: save)
                        .disabled(trimmedAuthKey == deepL.authKey)
                    Button("Remove key", role: .destructive) {
                        authKey = ""
                        deepL.authKey = ""
                    }
                    .disabled(!deepL.isConfigured)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            authKey = deepL.authKey
        }
    }

    private func save() {
        deepL.authKey = trimmedAuthKey
        authKey = trimmedAuthKey
    }
}

#Preview(traits: .modifier(EmptyDeck())) {
    SettingsView()
}
