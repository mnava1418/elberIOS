//
//  ElberController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 05/01/21.
//

import Foundation
import UIKit

enum ElberControllerLocalFunctions: String {
    case showCrypto = "showCrypto"
    case showChat = "showChat"
}

class ElberController {
    private var viewController:UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func processResponse(localFunction: String, parameters:Dictionary<String, Any>){
        switch localFunction {
        case ElberControllerLocalFunctions.showCrypto.rawValue:
            viewController.performSegue(withIdentifier: ElberControllerLocalFunctions.showCrypto.rawValue, sender: nil)
        default:
            print("Nothing more to do...")
        }
    }
}
