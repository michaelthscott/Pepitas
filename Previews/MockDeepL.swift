//
//  MockDeepL.swift
//  Pepitas
//
//  Created by Michael Scott on 29/09/2026.
//

import Foundation

/// Answers DeepL requests locally so translation works in previews without a key or network.
nonisolated final class MockDeepLProtocol: URLProtocol {
    /// A few canned translations; anything else comes back tagged so it's obviously fake.
    private static let phrasebook = [
        "hello": "olá",
        "thank you": "obrigado",
        "good morning": "bom dia",
    ]

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}

    override func startLoading() {
        guard let url = request.url,
              let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        let english = Self.text(in: request)
        let portuguese = Self.phrasebook[english.lowercased()] ?? "[PT] \(english)"
        let body = (try? JSONSerialization.data(withJSONObject: ["translations": [["text": portuguese]]])) ?? Data()

        // A short pause, on URLSession's loading thread, so the "Translating…" row is visible.
        Thread.sleep(forTimeInterval: 0.5)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    /// URLSession hands the body to a protocol as a stream, not as `httpBody`.
    private static func text(in request: URLRequest) -> String {
        guard let stream = request.httpBodyStream else { return "" }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (json?["text"] as? [String])?.first ?? ""
    }
}

extension DeepL {
    /// A DeepL client for previews that translates from a canned phrasebook.
    static func preview() -> DeepL {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockDeepLProtocol.self]
        return DeepL(session: URLSession(configuration: configuration), authKey: "preview:fx")
    }
}
