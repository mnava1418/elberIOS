//
//  SocketIOController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 26/12/20.
//

import Foundation
import SocketIO

struct SocketIOController {
    let manager:SocketManager!
    let socket:SocketIOClient!
    
    static let sharedInstance:SocketIOController = SocketIOController()
    
    init() {
        self.manager = SocketManager(socketURL: URL(string: Constants.HOST)!, config: [.log(false), .compress])
        self.socket = self.manager.defaultSocket
        
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Client connected...")
        }
        
        socket.on(clientEvent: .error) { (data, ack) in
            print("Error: \(data)")
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("Client disconnected...")
        }
        
        socket.on("elber response") { (data, ack) in
            if data.count > 0 {
                AudioController.sharedInstance.speak(message: data[0] as! String)
                ack.with("Got the response")
            }
        }
    }
    
    func startConnection () {
        if let _ = AppController.getToken() {
            if socket.status != .connected {
                socket.connect()
            }
        } else {
            AudioController.sharedInstance.speak(message: "No se quien eres. Lárgate de aquí")
        }
    }
    
    func closeConnection () {
        if socket.status == .connected {
            socket.disconnect()
        }
    }
    
    func sendMessage (message:String) {
        if let token = AppController.getToken() {
            if(socket.status == SocketIOStatus.connected) {
                socket.emit("elber request", "\(token)|\(message)")
            } else {
                AudioController.sharedInstance.speak(message: "Ya se cayo esta madre. Intenta mas tarde")
                startConnection()
            }
        } else {
            AudioController.sharedInstance.speak(message: "No se quien eres. Lárgate de aquí")
        }
    }
}
