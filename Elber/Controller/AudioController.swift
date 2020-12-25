//
//  AudioController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 24/12/20.
//

import Foundation
import AVFoundation

struct AudioController {
    let synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    public func speak(message:String){
        self.prepareAudioSession(audioCategory: AVAudioSession.Category.playback)
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.pitchMultiplier = 0.5
        synthesizer.speak(utterance)
    }
    
    public func prepareAudioSession(audioCategory: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(audioCategory)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fatalError("Error al inicializar audio session")
        }
    }
    
    fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
            return input.rawValue
    }
}
