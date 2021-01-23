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
    
    var socketIO:SocketIOController?
    
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
        tableView.register(UINib(nibName: "ReceiveMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "receiveMessageCell")
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
    
    private func addMessageToChat(message:String, type:MessageType) {
        let chatMessage = ElberMessage(message: message, type: type)
        self.elberMessages.append(chatMessage)
        let indexPath = IndexPath(row: self.elberMessages.count - 1, section: 0)
        
        if type == .receiver {
            self.tableView.insertRows(at: [indexPath], with: .left)
        } else {
            self.tableView.insertRows(at: [indexPath], with: .right)
        }
    
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.textViewLines = 1
        textView.text = ""
        self.textViewHeight.constant = minHeight - 16
        
        if message != "" {
            self.addMessageToChat(message: message, type: .sender)
            
            if let _ = socketIO {
                socketIO!.sendMessage(message: message, completion: { (response) in
                    var elberResponse = ""
                    if let error = response["error"] as? String {
                        elberResponse = error
                    } else {
                     elberResponse = response["elberResponse"] as! String
                    }
                    
                    self.addMessageToChat(message: elberResponse, type: .receiver)
                })
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
        
        if(elberMessage.type == .receiver) {
            return prepareReceiverMessage(elberMessage: elberMessage, indexPath: indexPath)
        }
        
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
        
        let width = estimateFrameForText(text: elberMessage.message).width + 45
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "MainBackground")
                
        cell.widthView.constant = width
        cell.textView.text = elberMessage.message
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    private func prepareReceiverMessage(elberMessage:ElberMessage, indexPath:IndexPath) -> ReceiveMessageTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! ReceiveMessageTableViewCell
        
        let width = estimateFrameForText(text: elberMessage.message).width + 45
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "MainBackground")
        
        cell.widthView.constant = width
        cell.textView.text = elberMessage.message
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
}
