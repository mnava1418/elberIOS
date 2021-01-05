//
//  ElberViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import UIKit
import WatchConnectivity

class ElberViewController: UIViewController {

    @IBOutlet weak var btnElber: UIButton!
    
    var socketController: SocketIOController!
    var speechController: SpeechController!
    var wcSession:WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        socketController = SocketIOController()
        speechController = SpeechController(btn: btnElber, socket: socketController)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateToken()
    }
    
    private func validateToken () {
        if let token = AppController.getToken() {
            self.socketController.startConnection()
            sendMessageToWatch(message: ["token": token])
        } else {
            self.socketController.closeConnection()
            UserModel.generateToken { (status, json) in
                if status == 200 {
                    let token = json["token"] as! String
                    AppController.saveToken(token: token) {
                        self.socketController.startConnection()
                        self.sendMessageToWatch(message: ["token": token])
                    }
                }
            }
        }
    }
    
    private func sendMessageToWatch(message: Dictionary<String, Any>) {
        wcSession.sendMessage(message) { (response) in
            print(response)
        } errorHandler: { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func touchElber(_ sender: Any) {
        if speechController!.audioEngine.isRunning {
            speechController!.stopRecording()
        } else {
            btnElber.animate()
            speechController!.startRecording { (response) in
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension UIButton {
    func animate () {
        let animation = ViewUtils.getAnimation()
        self.layer.add(animation, forKey: "pulse")
    }
}

extension ElberViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activated...")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session become inactive...")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session deactivate...")
    }
}
