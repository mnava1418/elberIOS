//
//  ElberViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import UIKit

class ElberViewController: UIViewController {

    @IBOutlet weak var btnElber: UIButton!
    
    var speechController: SpeechController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speechController = SpeechController(btn: btnElber)
        SocketIOController.sharedInstance.startConnection()
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
