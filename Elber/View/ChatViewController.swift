//
//  ChatViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 16/01/21.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chatViewBottom: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Chat"
        setTextView()
        addObservers()
    }
    
    private func setTextView () {
        self.textView.layer.cornerRadius = 10
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            
            let keyboardHeight = keyboardScreenEndFrame.height
            let safeHeight = self.parent!.view.safeAreaInsets.bottom * 2
            let constant = keyboardHeight - safeHeight
            
            self.chatViewBottom.constant = constant
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
