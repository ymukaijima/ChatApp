//
//  ChatlistViewController.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/06/30.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatlistViewController: UIViewController {

    @IBOutlet weak var chatlistTableView: UITableView!
    
    private var chatrooms = [ChatRoom]()
//    private var chatRoomListener: ListenerRegistration?
    
    private var user: User? {
        didSet {
            //Navbarのタイトルにログイン中のユーザーの名前を表示
            navigationItem.title = user?.userName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableViewに関する設定
        chatlistTableView.dataSource = self
        chatlistTableView.delegate = self
        chatlistTableView.register(UINib(nibName: K.chatlistCell, bundle: nil), forCellReuseIdentifier: K.chatlistCell)
        chatlistTableView.tableFooterView = UIView()
        
        //NavigationbarにAppタイトルを表示させる
        title = K.appName
        //Backボタンを消す
        navigationItem.hidesBackButton = true
        
        fetchLoginUserInfo()
        fetchChatroomsInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        fetchLoginUserInfo()
//        fetchChatroomsInfoFromFirestore()
    }
    
    private func fetchChatroomsInfoFromFirestore() {
        //Backボタンで戻った時にデータが二重で表示されるのを避ける
//        chatRoomListener?.remove()
//        chatrooms.removeAll()
//        chatlistTableView.reloadData()
        
//        chatRoomListener =
            Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, error) in
                
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
        }
//        chatlistTableView.reloadData()
    }
    
    //Chatlistの情報が更新された時に、更新された情報が追加される
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = chatroom.members.contains(uid)
        //もしチャットのメンバーに自分が含まれていなかったらチャットルームを表示させない
        if !isContain { return }
        
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, error) in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                    
                    guard let dic = userSnapshot?.data() else { return }
                    print("dic: ", dic)
                    
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    
                    guard let chatRoomId = chatroom.documentId else { return }
                    let latestMessageID = chatroom.latestMessageID
                    
                    //もしlatestMessageIDがnilだったときの処理
                    if latestMessageID == "" {
                        self.chatrooms.append(chatroom)
                        self.chatlistTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatRoomId).collection("messages").document(latestMessageID).getDocument { (messageSnapshot, error) in
                        if let e = error {
                            print(e.localizedDescription)
                            return
                        }
                        
                        guard let dic = messageSnapshot?.data() else { return }
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message
                        
                        self.chatrooms.append(chatroom)
                        self.chatlistTableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    //ログイン中のユーザー情報を取得
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            self.user = user
            
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ChatlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.chatlistCell, for: indexPath) as! ChatlistCell
        cell.chatroom = chatrooms[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        chatViewController.user = user
        chatViewController.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    //スワイプして削除する処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Firestoreからの削除処理
        self.deleteChatlistFromFirestore(indexPath)
        
        //Firestoreから削除した後に、配列からも削除する
        chatrooms.remove(at: indexPath.row)
        reloadChatlistTableView()
    }
    
    //Firestoreからの削除処理
    func deleteChatlistFromFirestore(_ indexPath:IndexPath){
        guard let documentId = chatrooms[indexPath.row].documentId else { return }
        Firestore.firestore().collection("chatRooms").document(documentId).delete()
    }

    func reloadChatlistTableView() {
        chatlistTableView.reloadData()
    }
    
}
