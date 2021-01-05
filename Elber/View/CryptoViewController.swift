//
//  CryptoViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 05/01/21.
//

import UIKit

class CryptoViewController: UIViewController {

    @IBOutlet weak var spotPrice: UILabel!
    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var sellPrice: UILabel!
    @IBOutlet weak var cryptoIcon: UIImageView!
    
    var data:Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setCrypto()
    }
    
    private func setCrypto() {
        if let cryptoInfo = data, !cryptoInfo.isEmpty {
            let crypto = cryptoInfo["crypto"] as! String
            let spot = cryptoInfo["spot"] as! String
            let buy = cryptoInfo["buy"] as! String
            let sell = cryptoInfo["sell"] as! String
            
            spotPrice.text = "\(spot) USD"
            buyPrice.text = "\(buy) USD"
            sellPrice.text = "\(sell) USD"
            cryptoIcon.image = UIImage(named: crypto)
            self.title = crypto
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
