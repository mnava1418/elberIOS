//
//  InterfaceController.swift
//  Elber WatchKit Extension
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var btnElber: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        SocketIOController.sharedInstance.startConnection()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func touchElber() {
        self.presentTextInputController(withSuggestions: ["Hola", "Huevos", "Gerardo es puto"], allowedInputMode: .plain) { (answers) in
            if let options = answers, options.count > 0 {
                if let message = options[0] as? String {
                    SocketIOController.sharedInstance.sendMessage(message: message)
                }
            }
        }
    }
}
