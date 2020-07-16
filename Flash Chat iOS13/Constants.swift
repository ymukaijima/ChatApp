//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/06/26.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

struct K {
    static let appName = "⚡️FlashChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let chatlistCell = "ChatlistCell"
    static let userlistCell = "UserlistCell"
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    static let chatlistToChatSegue = "ChatlistToChat"
    static let chatlistToUserlistSegue = "ChatlistToUserlist"
    static let userlistSegue = "UserlistToChat"
    static let userlistToChatlistSegue = "UserlistToChatlist"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
