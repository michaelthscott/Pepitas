# Changelog

All notable changes to Pepitas are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-21

First release, for iPhone.

### Added

- English–European Portuguese flashcards shown in random order. Tap the English
  side to flip the card, and tap the Portuguese side for the next card.
- The Portuguese side is spoken aloud when it's shown.
- A card editor with Save and Cancel. The fields grow to fit their text.
- Optional DeepL translation from English to European Portuguese (PT-PT). Your
  own API key is stored in the keychain.
- A Settings page with a link to DeepL API sign-up, an explanation of what is
  sent to DeepL, and the app version and build.
- Empty states with an Add card button when the deck has no cards.
- Privacy policy and support pages at
  [pepitas.michaelthscott.org](https://pepitas.michaelthscott.org).

### Fixed

- Flipping a card in a deck with only one card.
- The app uses a temporary deck if the card store can't be opened, so it no
  longer crashes.

[Unreleased]: https://github.com/michaelthscott/Pepitas/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/michaelthscott/Pepitas/releases/tag/v1.0.0
