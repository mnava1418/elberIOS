//
//  SendMessageTableViewCell.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 16/01/21.
//

import UIKit

class SendMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 16
        cellView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
