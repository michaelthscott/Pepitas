//
//  Speech.swift
//  Pepitas
//
//  Created by Michael Scott on 20/09/2026.
//

import Foundation
import Speech

@Observable final class Speech: NSObject, @unchecked Sendable {
    let synthesizer: AVSpeechSynthesizer
    let voice: AVSpeechSynthesisVoice?
    
    override init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt)
        } catch {
            print("Failed to set the audio session configuration")
        }
        synthesizer = AVSpeechSynthesizer()
        voice = AVSpeechSynthesisVoice(language: "pt-PT")
        super.init()
    }

    func speak(_ text: String) {
        guard let voice else {
            print("No voice for Portuguese")
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
}

