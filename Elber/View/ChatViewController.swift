//
//  ChatViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 16/01/21.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chatViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    var textViewLines:CGFloat!
    var minHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Chat"
        setTextView()
        addObservers()
    }
    
    private func setTextView () {
        self.textView.layer.cornerRadius = 10
        self.textView.delegate = self
        self.textViewLines = 1
        self.minHeight = textViewHeight.constant
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func adjustMessageView(increase: CGFloat) {
        let maxHeight:CGFloat = 150
        var newHeight = self.textViewHeight.constant + ( 25 * increase )
        
        if newHeight > maxHeight {
            newHeight = maxHeight
        } else if newHeight < minHeight {
            newHeight = minHeight
        }
        
        self.textViewHeight.constant = newHeight
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
            self.chatView.layoutIfNeeded()
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

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let currNum = textView.numberOfLines()
        if currNum != self.textViewLines {
            let difference:CGFloat = currNum - self.textViewLines
            self.adjustMessageView(increase: difference)
            self.textViewLines = currNum
        }
    }
}

extension UITextView {
    func numberOfLines() -> CGFloat {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines:CGFloat = 0

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            )
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
