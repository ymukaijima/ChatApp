//
//  User.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/02.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation
import Firebase

class User {
    let email: String
    let userName: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.userName = dic["userName"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}
