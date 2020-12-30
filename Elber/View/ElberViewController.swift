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
    
    var speechController: SpeechController?
    var wcSession:WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speechController = SpeechController(btn: btnElber)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
        validateToken()
    }
    
    private func validateToken () {
        if let token = AppController.getToken() {
            SocketIOController.sharedInstance.startConnection()
            sendMessageToWatch(message: ["token": token])
        } else {
            SocketIOController.sharedInstance.closeConnection()
            UserModel.generateToken { (status, json) in
                if status == 200 {
                    let token = json["token"] as! String
                    AppController.saveToken(token: token) {
                        SocketIOController.sharedInstance.startConnection()
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
            speechController!.startRecording()
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
