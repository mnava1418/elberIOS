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
    @IBOutlet weak var listeningLabel: WKInterfaceLabel!
    
    var isListening = false
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func touchElber() {
        if isListening {
            listeningLabel.setHidden(true)
            btnElber.setWidth(120)
            btnElber.setWidth(120)
            isListening = false
        } else {
            listeningLabel.setHidden(false)
            btnElber.setWidth(136)
            btnElber.setWidth(136)
            isListening = true
        }
    }
}
