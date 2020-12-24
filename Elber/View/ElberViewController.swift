//
//  ElberViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import UIKit

class ElberViewController: UIViewController {

    @IBOutlet weak var btnElber: UIButton!
    
    var isListening = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchElber(_ sender: Any) {
        if isListening {
            btnElber.layer.removeAllAnimations()
            isListening = false
        } else {
            btnElber.animate()
            isListening = true
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
