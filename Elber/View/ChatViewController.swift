//
//  ChatViewController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 16/01/21.
//

import UIKit

enum MessageType {
    case sender
    case receiver
}

struct ElberMessage {
    let message:String
    let type:MessageType
    
    init(message: String, type:MessageType) {
        self.message = message
        self.type = type
    }
}

class ChatViewController: UIViewController {

    @IBOutlet weak var chatView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chatViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var sendBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var textViewLines:CGFloat!
    var minHeight:CGFloat!
    var elberMessages:[ElberMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Chat"
        setTextView()
        setTableView()
        addObservers()
    }
    
    private func setTableView() {
        tableView.register(UINib(nibName: "SendMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "sendMessageCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    private func setTextView () {
        self.textView.layer.cornerRadius = 10
        self.textView.delegate = self
        self.textViewLines = 1
        self.minHeight = textViewHeight.constant
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func adjustMessageView(increase: CGFloat) {
        let maxHeight:CGFloat = 160
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
        removeObservers()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            
            let keyboardHeight = keyboardScreenEndFrame.height
            let safeHeight = self.parent!.view.safeAreaInsets.bottom * 2
            let constant = keyboardHeight - safeHeight
            adjustChatView(constant: constant, bottom: 0, height: 16)
        }
    }
    
    @objc func keyboardWillHide() {
        adjustChatView(constant: 0, bottom: 16, height: 0)
        self.textView.resignFirstResponder()
    }
    
    private func adjustChatView(constant:CGFloat, bottom:CGFloat, height:CGFloat) {
        self.chatViewBottom.constant = constant
        self.textViewBottom.constant = bottom
        self.sendBtnBottom.constant = bottom
        self.textViewHeight.constant = minHeight - height
        self.chatView.layoutIfNeeded()
        
        if self.elberMessages.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: self.elberMessages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.textViewLines = 1
        textView.text = ""
        self.textViewHeight.constant = minHeight - 16
        
        if message != "" {
            let elberMessage = ElberMessage(message: message, type: .sender)
            self.elberMessages.append(elberMessage)
            
            let indexPath = IndexPath(row: self.elberMessages.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .right)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        if currNum != self.textViewLines && currNum > 0 {
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elberMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elberMessage = elberMessages[indexPath.row]
        return prepareSenderMessage(elberMessage: elberMessage, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let elberMessage = elberMessages[indexPath.row]
        let height = estimateFrameForText(text: elberMessage.message).height + 50
        return height
    }
    
    private func estimateFrameForText(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], context: nil)
    }
    
    private func prepareSenderMessage(elberMessage:ElberMessage, indexPath:IndexPath) -> SendMessageTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
        
        let width = estimateFrameForText(text: elberMessage.message).width + 30
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "MainBackground")
        
        cell.cellView.translatesAutoresizingMaskIntoConstraints = false
        cell.cellView.widthAnchor.constraint(equalToConstant: width).isActive = true
        cell.textView.text = elberMessage.message
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
}
