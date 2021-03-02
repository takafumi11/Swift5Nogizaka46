//
//  LoginViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/01.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var userInfo:[UserInfo] = []
    var userInfo2:[UserInfo2] = []
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error != nil {
                print(error.debugDescription)
                print("ログインに失敗しました。")
            }else{
                print("ログインに成功しました!!")
                self.linkUserInfo()
                self.performSegue(withIdentifier: "home", sender: nil)
            }
        }
    }
    
    func linkUserInfo(){
        Firestore.firestore().collection("メールアドレスとユーザーネームの紐付け").addSnapshotListener() { (snapShot, error) in
            self.userInfo = []
            
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        
                        if let email = data["email"],let userName = data["userName"]{
                            let newInfo = UserInfo(email: email as! String, userName: userName as! String)
                            
                            self.userInfo.append(newInfo)
                        }
                    }
                }
            
                for i in 0...self.userInfo.count-1{
                    if self.userInfo[i].email == Auth.auth().currentUser?.email{
                        UserDefaults.standard.set(self.userInfo[i].userName, forKey: "userName")
                    }
                }
            }
        
        Firestore.firestore().collection("メールアドレスと写真の紐付け").addSnapshotListener() { (snapShot, error) in
        self.userInfo2 = []

            if error != nil{
                print(error.debugDescription)
                return
            }

            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let email = data["email"],let profileImage = data["profileImage"]{

                        let newInfo2 = UserInfo2(email: email as! String, profileImage:profileImage as! String)

                        self.userInfo2.append(newInfo2)
                    }
                }
            }

            for i in 0...self.userInfo2.count-1{
                if self.userInfo2[i].email == Auth.auth().currentUser?.email{
                    let url = self.userInfo2[i].profileImage
                    UserDefaults.standard.setValue(url, forKey: "userImage")
                }
            }
            
        }
    }
}

    


