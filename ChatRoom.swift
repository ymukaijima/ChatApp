//
//  File.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/02.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {
    
    let members: [String]
    let latestMessageID: String
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.members = dic["members"] as? [String] ?? [String]()
        self.latestMessageID = dic["latestMessageID"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
