//
//  SocketIphoneController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 04/01/21.
//

import UIKit

class SocketIphoneController: SocketIOController {
    var viewController:UIViewController!
    
    init(source:SocketSource, view:UIViewController) {
        super.init(source: source)
        self.viewController = view
    }
}
