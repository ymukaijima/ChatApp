//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2
        userNameTextfield.layer.cornerRadius = userNameTextfield.frame.size.height / 4
        userNameTextfield.layer.borderWidth = 0
        userNameTextfield.layer.borderColor = .none
//        registerButton.layer.cornerRadius = registerButton.frame.size.height / 4
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        userNameTextfield.delegate = self
        
    }
    
    @IBAction func profileImageViewPressed(_ sender: Any) {
        //ImagePickerを使って画像を取得する
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
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
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
        
    }
    
    private func createUserToFirestore(profileImageUrl: String) {
        //registerButtonをおしたときにFirebaseに情報を保存する
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    
                    guard let uid = authResult?.user.uid else { return }
                    guard let userName = self.userNameTextfield.text else { return }
                    let docData = [
                        "email": email,
                        "userName": userName,
                        "createdAt": Timestamp(),
                        "profileImageUrl": profileImageUrl
                        ] as [String : Any]
                    
                    Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
                        if let e = error {
                            print(e.localizedDescription)
                            return
                        }
                        //問題なく情報が保存できたらChatlistへ遷移
                        self.performSegue(withIdentifier: K.registerSegue, sender: self)
                    }
                }
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextfield.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextfield.text?.isEmpty ?? false
        let userNameIsEmpty = userNameTextfield.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            registerButton.isEnabled = false
        } else {
            registerButton.isEnabled = true
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePickerで画像を保存する設定
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
        profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}
