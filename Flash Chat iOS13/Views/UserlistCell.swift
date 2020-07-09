//
//  UserlistCell.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/02.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Nuke

class UserlistCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var user: User? {
        didSet {
            userNameLabel.text = user?.userName
            
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
