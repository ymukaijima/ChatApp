//
//  UserlistViewController.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/02.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class UserlistViewController: UIViewController {

    @IBOutlet weak var userlistTableView: UITableView!
    @IBOutlet weak var startTalkingButton: UIButton!
    
    private var users = [User]()
    private var selectedUsers: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userlistTableView.delegate = self
        userlistTableView.dataSource = self
        userlistTableView.register(UINib(nibName: K.userlistCell, bundle: nil), forCellReuseIdentifier: K.userlistCell)
        userlistTableView.tableFooterView = UIView()
        // UITableView全体は複数選択可能に設定
//        userlistTableView.allowsMultipleSelection = true
//        userlistTableView.isEditing = true
//        userlistTableView.allowsMultipleSelectionDuringEditing = true
        
        //最初はStart Talkingボタンをおせないようにしておく
        startTalkingButton.isEnabled = false
        
        fetchUserInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Tab barを表示させる
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func startTalkingButtonPressed(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUsers?.uid else { return }
        let members = [uid, partnerUid]
        
        let docData = [
            "members": members,
            "latestMessageID": "",
            "createdAt": Timestamp()
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            //会話したいメンバーを選んだあとに、Chatlistへ戻る
            self.performSegue(withIdentifier: K.userlistToChatlistSegue, sender: self)
        }
    }
    
    
    private func fetchUserInfoFromFirestore() {
        
        Firestore.firestore().collection("users").getDocuments { (snapshots, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                //現在ログイン中のユーザーはユーザーリストに表示しないようにする
                guard let uid = Auth.auth().currentUser?.uid else { return }
                if uid == snapshot.documentID {
                    return
                }
                
                self.users.append(user)
                self.userlistTableView.reloadData()
            })
        }
    }
}

extension UserlistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userlistTableView.dequeueReusableCell(withIdentifier: K.userlistCell, for: indexPath) as! UserlistCell
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startTalkingButton.isEnabled = true
        
        let user = users[indexPath.row]
//        let users = userlistTableView.indexPathsForSelectedRows
//        print("users: ",users)
//
//        print("indexPath.row: ",indexPath.row)
//        print("self.selectedUsers: ",self.selectedUsers)
        
        self.selectedUsers = user
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
