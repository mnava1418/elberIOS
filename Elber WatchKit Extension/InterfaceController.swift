//
//  InterfaceController.swift
//  Elber WatchKit Extension
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var btnElber: WKInterfaceButton!
    
    var wcSession : WCSession!
    var socketController: SocketIOController!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
        socketController = SocketIOController()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        socketController.startConnection()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func touchElber() {
        self.presentTextInputController(withSuggestions: ["Precio del Bitcoin", "Hola", "Gerardo es puto"], allowedInputMode: .plain) { (answers) in
            if let options = answers, options.count > 0 {
                if let message = options[0] as? String {
                    self.socketController.sendMessage(message: message) { (response) in
                        var elberResponse = ""
                        if let error = response["error"] as? String {
                            elberResponse = error
                        } else {
                            elberResponse = response["elberResponse"] as! String
                        }
                        
                        AudioController.sharedInstance.speak(message: elberResponse)
                    }
                }
            }
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activated...")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let token = message["token"] as? String {
            AppController.saveToken(token: token) {
                socketController.startConnection()
            }
        }
        replyHandler(["ok":"ok"])
    }
}
