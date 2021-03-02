//
//  SelectViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/01.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SelectViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backView.layer.cornerRadius = 20.0
        view.backgroundColor = .systemGroupedBackground
        
    }
    
    @IBAction func anonymousLoginBtn(_ sender: Any) {
        Auth.auth().signInAnonymously { (result, error) in
            if error != nil{
                print(error.debugDescription)
                print("ログインに失敗しました")
            }else{
                print("ログインに成功しました!!")
            }
            
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "userImage")
            UserDefaults.standard.removeObject(forKey: "email")
            
            let home = self.storyboard?.instantiateViewController(identifier: "home") as! TabBarController
            self.navigationController?.pushViewController(home, animated: true)        
        }
    }
}
