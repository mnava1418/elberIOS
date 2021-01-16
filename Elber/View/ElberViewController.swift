//
//  ElberViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import UIKit
import WatchConnectivity
import AVFoundation

class ElberViewController: UIViewController {

    @IBOutlet weak var btnElber: UIButton!
    
    var socketController: SocketIOController!
    var speechController: SpeechController!
    var elberController: ElberController!
    var wcSession:WCSession!
    var localFunction:String?
    var localParameters:Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        elberController = ElberController(viewController: self)
        socketController = SocketIOController()
        speechController = SpeechController(btn: btnElber, socket: socketController)
        
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
        setNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateToken()
    }
    
    private func setNavBar() {
        let chatImg = UIImage(systemName: "message")
        let showChatBtn = UIBarButtonItem(image: chatImg, style: .plain, target: self, action: #selector(showChat))
        self.navigationItem.rightBarButtonItem = showChatBtn
    }
    
    @objc private func showChat() {
        self.performSegue(withIdentifier: "showChat", sender: nil)
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
            self.btnElber.isEnabled = false
            speechController!.stopRecording()
        } else {
            btnElber.animate()
            speechController!.startRecording { (response) in
                var elberResponse = ""
                if let error = response["error"] as? String {
                    elberResponse = error
                } else {
                    elberResponse = response["elberResponse"] as! String
                    self.localFunction = response["localFunction"] as? String
                    self.localParameters = response["parameters"] as? Dictionary<String, Any>
                }
                
                AudioController.sharedInstance.speak(message: elberResponse)
                
                if let function = self.localFunction, let parameters = self.localParameters {
                    self.elberController.processResponse(localFunction: function, parameters: parameters)
                }
                
                self.localFunction = nil
                self.localParameters = nil
                self.btnElber.isEnabled = true
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch localFunction {
        case ElberControllerLocalFunctions.showCrypto.rawValue:
            let destination = segue.destination as! CryptoViewController
            destination.data = self.localParameters
        default:
            print("Nothing to prepare...")
        }
        
        self.localFunction = nil
        self.localParameters = nil
    }
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
