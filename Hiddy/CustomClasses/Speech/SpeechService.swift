//
//  SpeechService.swift
//  Hiddy
//
//  Created by HaiDeR AwAn on 02/03/2023.
//  Copyright © 2023 HITASOFT. All rights reserved.
//

import Foundation
import AVKit
import NaturalLanguage
import Speech


class SpeechService: NSObject {
    
    static let shared = SpeechService()
    let speechSynthesizer = AVSpeechSynthesizer()
    
//    MARK: - Speech Methods
    
    func startSpeech(_ text: String) {
        let languageCode = detectedLanguage(for: text)
        self.stopSpeaking()
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
            let utterence = AVSpeechUtterance(string: text)
            utterence.voice = AVSpeechSynthesisVoice(language: language)
            utterence.voice = AVSpeechSynthesisVoice(language: languageCode)
            utterence.rate = 0.5
            speechSynthesizer.speak(utterence)
        }
    }
 
    func stopSpeaking() {
//        DispatchQueue.main.async {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
//        }
        
    }
    
    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        let _ = Locale.current.localizedString(forIdentifier: languageCode)
        return languageCode
    }
}
