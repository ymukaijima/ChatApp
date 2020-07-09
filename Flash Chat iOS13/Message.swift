//
//  Message.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/06/26.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation
import Firebase

//struct Message {
//    let sender: String
//    let body: String
//}

class Message {
    
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    //後で消すかも
    var sender: String?
    var body: String?
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}


