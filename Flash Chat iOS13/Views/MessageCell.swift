//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/06/27.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var message: Message? {
        didSet {
            if let message = message {
                label.text = message.message
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
        leftImageView.layer.cornerRadius = leftImageView.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
