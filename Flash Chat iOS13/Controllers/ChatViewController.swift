//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var user: User?
    var chatroom: ChatRoom?
    
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableViewの設定
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        //NavigationbarにAppタイトルを表示させる
        title = K.appName
        //Tab barを隠す
        self.tabBarController?.tabBar.isHidden = true
        
        chatTableView.reloadData()
        loadMessages()
        
    }
    
    func loadMessages() {

        guard let chatroomDocId = chatroom?.documentId else { return }
        print("chatroomDocId: ", chatroomDocId)
        
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    self.messages.append(message)
                    //追加された順にソートする
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    self.chatTableView.reloadData()
                    //新しくデータが追加されたら、最新の情報が見れるよう画面に表示する（最新の情報が隠れないようにする）
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        guard let messageBody = messageTextfield.text else { return }
        addMessageToFirestore(messageBody: messageBody)
    }
    
    private func addMessageToFirestore(messageBody: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.userName else { return }
        let messageId = randomString(length: 20)
        
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": messageBody
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            let latestMessageData = [
                "latestMessageID": messageId
            ]
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (error) in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
            }
            //メッセージが送れたらTextfieldをクリアにする
            DispatchQueue.main.async {
                self.messageTextfield.text = ""
            }
            
            self.chatTableView.reloadData()
        }
    }
    
    //latestMessageIDに入れるIDを生成（ChatlistCellに反映させるためのID）
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }
        
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.message
        
        //現在ログインしているユーザーのメッセージをどのように表示させるか決める
        if message.uid == Auth.auth().currentUser?.uid {
            cell.leftImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        //他のユーザーからのメッセージをどのように表示させるか決める
        else {
            cell.leftImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            if let urlString = message.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: cell.leftImageView)
            }
        }
        return cell
    }
}
