# ``Pepitas``

A simple European Portuguese flashcards app.

## Overview

Uses the DeepL API to translate English phrases to European Portuguese. The flashcards are displayed randomly, first in English and then in Portuguese. The cards are flipped by tapping the English text. The Portuguese text is spoken when displayed. Tapping the Portuguese text displays the next card.

## Translating with DeepL

Typing the back of every card by hand is the slow part of building a deck, so the app fills
it in for you. Enter the English phrase on the front of a card and the Portuguese
translation arrives from DeepL a moment later.

### Getting an API key

Translation is off until you supply a DeepL API key, because the key is tied to your own
account and quota rather than shipped with the app.

1. Create a DeepL API account at [deepl.com/pro-api](https://www.deepl.com/pro-api) and
   copy the authentication key from the account page. The free plan allows 500,000
   characters per month, which is a lot of flashcards.
2. Open the **Settings** tab in Pepitas, paste the key into the **DeepL** field, and tap
   **Save**. **Remove key** deletes it again.

The key is written to the keychain by `KeychainItem`, not to `UserDefaults` or the app
bundle, so it is never part of the project source and survives across launches.

Free and Pro accounts are served from different hosts. `DeepL` picks the right one from the
key itself: free keys carry a `:fx` suffix and are sent to `api-free.deepl.com`, everything
else goes to `api.deepl.com`. There is nothing to configure either way.

### Translating a card

`CardEditor` starts a translation when you submit the **Front** field — pressing return
moves the keyboard to **Back** and kicks off the request at the same time. A
"Translating…" row appears below the **Back** field while the request is in flight, and the
result replaces whatever **Back** currently holds.

Each editor keeps at most one request alive. Submitting the front again cancels the
previous request, and leaving the editor cancels it too, so a slow response can never
overwrite a card you have moved on from.

### Calling the API directly

`DeepL` is an `@Observable` service injected through the environment alongside `Deck` and
`Speech`, so any view can reach it:

```swift
@Environment(DeepL.self) private var deepL

let portuguese = try await deepL.portuguese(for: "Good morning")
```

`portuguese(for:)` sends a single POST to the DeepL v2 `translate` endpoint with
`source_lang` set to `EN` and `target_lang` set to `PT-PT` — European rather than Brazilian
Portuguese — and returns the first translation in the response. Text that is empty or only
whitespace returns an empty string without touching the network.

Use `isConfigured` to check whether a key has been entered before offering translation as
an option.

### Handling failures

Anything that goes wrong is reported as a `TranslationError`, whose `errorDescription`
is written for display straight to the reader:

| Case | Cause |
| --- | --- |
| `missingAuthKey` | No key has been saved in Settings yet. |
| `authorizationFailed` | DeepL rejected the key (HTTP 403). |
| `quotaExhausted` | The monthly character allowance is used up (HTTP 456). |
| `rateLimited` | Too many requests in too short a time (HTTP 429 or 529). |
| `emptyResponse` | DeepL accepted the request but returned no translation. |
| `unexpectedStatus` | Any other non-200 status, carrying the code. |
| `invalidEndpoint` | The request URL could not be formed. |
