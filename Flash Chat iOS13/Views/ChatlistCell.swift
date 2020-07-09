//
//  ChatlistCell.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/06/30.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatlistCell: UITableViewCell {

    @IBOutlet weak var chatlistImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var chatlistNameLabel: UILabel!
    @IBOutlet weak var chatlistDateLabel: UILabel!
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                chatlistNameLabel.text = chatroom.partnerUser?.userName
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: chatlistImageView)
                
                chatlistDateLabel.text = dateFormatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                    
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chatlistImageView.layer.cornerRadius = chatlistImageView.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
