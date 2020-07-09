//
//  UserDetailViewController.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/09.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class UserDetailViewController: UIViewController {
    

    @IBOutlet weak var profileImageView: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchLoginUserInfo()
    }
    
    func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            
            self.userNameTextField.text = user.userName
        }
    }
}
