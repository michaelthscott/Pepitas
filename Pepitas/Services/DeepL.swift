//
//  DeepL.swift
//  Pepitas
//
//  Created by Michael Scott on 21/09/2026.
//

import Foundation

/// A failure encountered while translating with the DeepL API.
nonisolated enum TranslationError: LocalizedError {
    case missingAuthKey
    case invalidEndpoint
    case authorizationFailed
    case quotaExhausted
    case rateLimited
    case emptyResponse
    case unexpectedStatus(Int)

    /// Maps the status codes documented for the DeepL v2 API onto the cases above.
    init(statusCode: Int) {
        switch statusCode {
        case 403: self = .authorizationFailed
        case 456: self = .quotaExhausted
        case 429, 529: self = .rateLimited
        default: self = .unexpectedStatus(statusCode)
        }
    }

    var errorDescription: String? {
        switch self {
        case .missingAuthKey:
            return String(localized: "Add a DeepL API key in Settings to translate automatically.")
        case .invalidEndpoint:
            return String(localized: "The DeepL address could not be formed.")
        case .authorizationFailed:
            return String(localized: "DeepL rejected the API key. Check it in Settings.")
        case .quotaExhausted:
            return String(localized: "This month's DeepL translation quota is used up.")
        case .rateLimited:
            return String(localized: "Too many requests to DeepL. Try again in a moment.")
        case .emptyResponse:
            return String(localized: "DeepL returned no translation.")
        case .unexpectedStatus(let code):
            return String(localized: "DeepL returned an unexpected response (\(code)).")
        }
    }
}

/// Translates English text into European Portuguese using the DeepL API.
///
/// The authentication key is held in the keychain rather than in the app bundle, so it
/// survives reinstalls of the deck but is never checked into the project.
@Observable final class DeepL {
    private static let keychainItem = KeychainItem(service: "org.michaelthscott.Pepitas",
                                                   account: "DeepLAuthKey")

    /// The DeepL authentication key. Assigning writes through to the keychain; assigning an
    /// empty string removes the stored key.
    var authKey: String {
        didSet { Self.keychainItem.write(authKey) }
    }

    /// Whether a key has been entered, and so whether translation can be attempted.
    var isConfigured: Bool { !authKey.isEmpty }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        authKey = Self.keychainItem.read() ?? ""
    }

    /// Translates `text` from English into European Portuguese.
    ///
    /// - Returns: The translation, or an empty string when `text` has nothing to translate.
    func portuguese(for text: String) async throws -> String {
        let english = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !english.isEmpty else { return "" }
        guard isConfigured else { throw TranslationError.missingAuthKey }
        guard let endpoint else { throw TranslationError.invalidEndpoint }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("DeepL-Auth-Key \(authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            TranslationRequest(text: [english], sourceLanguage: "EN", targetLanguage: "PT-PT")
        )

        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw TranslationError(statusCode: response.statusCode)
        }

        let translations = try JSONDecoder().decode(TranslationResponse.self, from: data).translations
        guard let translation = translations.first else { throw TranslationError.emptyResponse }
        return translation.text
    }

    /// DeepL serves free accounts from a separate host. Free keys carry a ":fx" suffix.
    private var endpoint: URL? {
        let host = authKey.hasSuffix(":fx") ? "api-free.deepl.com" : "api.deepl.com"
        return URL(string: "https://\(host)/v2/translate")
    }
}

private nonisolated struct TranslationRequest: Encodable {
    let text: [String]
    let sourceLanguage: String
    let targetLanguage: String

    enum CodingKeys: String, CodingKey {
        case text
        case sourceLanguage = "source_lang"
        case targetLanguage = "target_lang"
    }
}

private nonisolated struct TranslationResponse: Decodable {
    struct Translation: Decodable {
        let text: String
    }

    let translations: [Translation]
}
