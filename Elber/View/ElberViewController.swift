//
//  ElberViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 23/12/20.
//

import UIKit

class ElberViewController: UIViewController {

    @IBOutlet weak var btnElber: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchElber(_ sender: Any) {
        print("Hola!")
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
