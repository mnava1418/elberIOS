//
//  SocketIOController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 26/12/20.
//

import Foundation
import SocketIO


class SocketIOController {
    let manager:SocketManager!
    let socket:SocketIOClient!
    
    init() {
        self.manager = SocketManager(socketURL: URL(string: Constants.HOST)!, config: [.log(false), .compress])
        self.socket = self.manager.defaultSocket
    }
    
    func startConnection () {
        if let _ = AppController.getToken() {
            if socket.status != .connected {
                socket.connect()
            }
        }
    }
    
    func closeConnection () {
        if socket.status == .connected {
            socket.disconnect()
        }
    }
    
    func sendMessage (message:String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        if let token = AppController.getToken() {
            if(socket.status == SocketIOStatus.connected) {
                socket.emit("elber request", "\(token)|\(message)")
                socket.on("elber response") { (data, ack) in
                    self.socket.off("elber response")
                    if data.count > 0 {
                        let response = data[0] as! Dictionary<String, Any>
                        completion(response)
                    }
                }
            } else {
                let response = ["error": "Ya se cayo esta madre. Intenta mas tarde"]
                startConnection()
                completion(response)
            }
        } else {
            let response = ["error": "No se quien eres. Lárgate de aquí"]
            completion(response)
        }
    }
}

