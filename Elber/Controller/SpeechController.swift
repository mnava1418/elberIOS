//
//  SpeechController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 24/12/20.
//

import Foundation
import UIKit
import Speech

class SpeechController {
    
    var recognitionTask: SFSpeechRecognitionTask?
    var audioInputNode: AVAudioInputNode?
    var speechTimer:Timer?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    let audioEngine: AVAudioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier:"es-mx"))
    let btnElber:UIButton!
    
    init(btn: UIButton) {
        btnElber = btn
    }
    
    private func recognitionTaskHandler(res: SFSpeechRecognitionResult?, err: Error?) {
        var isLast = false
        if res != nil {
            isLast = (res?.isFinal)!
        }
        
        if err != nil || isLast {
            audioEngine.stop()
            audioInputNode?.removeTap(onBus: 0)
            recognitionRequest = nil
            recognitionTask = nil
            
            if(err != nil) {
                AudioController.sharedInstance.speak(message: "Perdona. No te entendí")
            }else{
                let bestStr = res?.bestTranscription.formattedString
            
                if let mensaje = bestStr {
                    SocketIOController.sharedInstance.sendMessage(message: mensaje)
                } else{
                    AudioController.sharedInstance.speak(message: "Perdona. No te entendí")
                }
            }
        } else if( !isLast){
            self.speechTimer?.invalidate()
            self.speechTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopRecording), userInfo: nil,repeats: false)
        }
    }
    
    @objc public func stopRecording() {
        btnElber.layer.removeAllAnimations()
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    public func startRecording() {
        if let _ = recognitionTask {
            recognitionTask!.cancel()
            recognitionTask = nil
        }
        
        AudioController.sharedInstance.prepareAudioSession(audioCategory: AVAudioSession.Category.record)
        audioInputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recRequest = recognitionRequest else {
            fatalError("Error al crear recognition request")
        }
        
        recRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recRequest) {
            res, err in
            self.recognitionTaskHandler(res: res, err: err)
        }
        
        let format = audioInputNode?.outputFormat(forBus: 0)
        audioInputNode?.installTap(onBus: 0, bufferSize: 1024, format: format) {
            buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            fatalError("Can't start the engine")
        }
    }
}
