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
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func didAppear() {
        super.didAppear()
        SocketIOController.sharedInstance.startConnection()
    }

    @IBAction func touchElber() {
        self.presentTextInputController(withSuggestions: ["Que hora es?", "Hola", "Gerardo es puto"], allowedInputMode: .plain) { (answers) in
            if let options = answers, options.count > 0 {
                if let message = options[0] as? String {
                    SocketIOController.sharedInstance.sendMessage(message: message)
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
                SocketIOController.sharedInstance.startConnection()
            }
        }
        replyHandler(["ok":"ok"])
    }
}
