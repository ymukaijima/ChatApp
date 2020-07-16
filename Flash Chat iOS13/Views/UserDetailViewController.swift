//
//  UserDetailViewController.swift
//  Flash Chat iOS13
//
//  Created by yumi on 2020/07/09.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import PKHUD

class UserDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 5
        
        //Nav barのタイトルはなし
        title = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchLoginUserInfo()
    }

    //ImageViewをタップしたときの動作
    @IBAction func tappedProfileImageView(_ sender: Any) {
        print("imageViewをタップしたよ")
        //アクションシートを表示する
        let alertSheet = UIAlertController(title: nil, message: "選択してください", preferredStyle: .actionSheet)
        //最初に設定したImageViewを変更するとき
        let albumAction = UIAlertAction(title: "写真を変更する", style: .default) { (action) in
            print("写真の変更が選択されました")
            self.presentPicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            print("キャンセルが選択されました")
        }
        //それぞれのアクションを紐付け
        alertSheet.addAction(albumAction)
        alertSheet.addAction(cancelAction)
        
        //アラートシートを表示
        present(alertSheet, animated: true)
    }
    
    //アルバムとカメラの画面を生成する関数
    func presentPicker(sourceType:UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            //ソースタイプが利用できるとき
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            
            //デリゲート先に自らのクラスを指定
            picker.delegate = self
            //画面を表示する
            present(picker, animated: true, completion: nil)
        } else {
            print("The SourceType is not found")
        }
    }
    
    //画像を選択したら呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        print("画像を選択したよ!")
        if let pickedImage = info[.originalImage] as? UIImage{
            //撮影or選択した画像をimageViewの中身に入れる
            profileImageView.image = pickedImage
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.clipsToBounds = true
        }
        //表示した画面を閉じる処理
        picker.dismiss(animated: true, completion: nil)
    }
        
    //ログインしているユーザーの情報を取得
    func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists {
                let dic = snapshot.data()
                let user = User(dic: dic!)
                self.userNameTextField.text = user.userName
                
                guard let url = URL(string: user.profileImageUrl) else { return }
                Nuke.loadImage(with: url, into: self.profileImageView)
                //profileImageViewの枠にはまるように設置
                self.profileImageView.contentMode = .scaleAspectFill
                self.profileImageView.clipsToBounds = true
                
            } else {
                print("Snapshot does not exists.")
                self.userNameTextField.placeholder = "Please register your profile or login."
            }
        }
    }
    
    // SaveButtonをタップしたときの動作
    @IBAction func tappedSaveButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid,
            let userName = userNameTextField.text,
            let image = profileImageView.image,
            let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        //Storageに画像データを保存
        storageRef.putData(uploadImage, metadata: nil) { (metadata, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            storageRef.downloadURL { (url, error) in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                //Firestoreでの更新処理
                self.updateToFirestore(uid, userName: userName, profileImageUrl: urlString)
                HUD.flash(.success, delay: 0.3)
            }
        }
    }
    
    //Firestoreでの更新処理
    func updateToFirestore(_ uid: String, userName: String, profileImageUrl: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists {
                let dic = snapshot.data()
                let user = User(dic: dic!)
                
                let docData = [
                    "email": user.email,
                    "userName": userName,
                    "createdAt": Timestamp(),
                    "profileImageUrl": profileImageUrl
                    ] as [String : Any]
                
                Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
                    if let e = error {
                        print(e.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}

