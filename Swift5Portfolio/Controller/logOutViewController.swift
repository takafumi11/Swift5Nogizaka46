//
//  logOutViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/12.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import WebKit
import SwiftyStoreKit
import FirebaseAuth

protocol CatchProtocol {
    func catchData(count:Int)
}

class logOutViewController: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var movieCount: UILabel!
    @IBOutlet weak var articleCount: UILabel!
    @IBOutlet weak var blogCount: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    
    var webView = WKWebView()
    
    
    //課金
    var count:Int = 0
    var delegate:CatchProtocol?
    
    var docID = ""
    var ccount:Int = 0
    var userInfo2:[UserInfo2] = []
    
    var imageString = String()
    
    var bCount:Int = 0
    var nCount:Int = 0
    var mCount:Int = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userNameLabel.text = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        }else{
            imageString = ""
        }
        
        if imageString != ""{
            profileImageView.sd_setImage(with: URL(string: imageString), completed:nil)
        }
        
        if Auth.auth().currentUser?.email == nil{
            logOutBtn.isHidden = true
        }else{
            editBtn.isHidden = true
        }

  
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            
            let docid = Firestore.firestore().collection("メールアドレスと写真の紐付け").document().path
                                    
            let idx = docid.index(of: "/")
            let idx2 = docid.index(after: idx!)
            
            
            //ここで取得しておかないと後で書き換えるときにdocumentの指定ができない
            docID = String(docid[idx2...])
            print("kjh")
            print(docID)
            Firestore.firestore().collection("メールアドレスと写真の紐付け").document(docID).setData(["email":Auth.auth().currentUser?.email,"profileImage":UserDefaults.standard.object(forKey: "userImage")!])
            
            checkImage()
        }
        
        if (UserDefaults.standard.object(forKey: "userName") != nil) && (UserDefaults.standard.object(forKey: "email") != nil){
            print(UserDefaults.standard.object(forKey: "userName")!)
            print(UserDefaults.standard.object(forKey: "email")!)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func purchase(PRODUCT_ID:String){
           
       SwiftyStoreKit.purchaseProduct(PRODUCT_ID) { (result) in
           
           switch result{
               
           case .success(_):
            //購入が成功したとき
               
               if let buy = UserDefaults.standard.object(forKey: "buy"){
                   let count = UserDefaults.standard.object(forKey: "buy") as! Int
          
               }else{
                   self.count = 1
                   UserDefaults.standard.set(1, forKey: "buy")
               }
                              
            print("変えたよ!!")
               self.verifyPurchase(PRODUCT_ID:PRODUCT_ID)
              
               self.delegate?.catchData(count: self.count)
               self.dismiss(animated: true, completion: nil)
               
               break
           case .error(let error):
               print(error)
               
               break
           }
       }
    }
    
    func verifyPurchase(PRODUCT_ID:String){
        //共有シークレット リストア
        let appeValidator = AppleReceiptValidator(service: .production, sharedSecret: "8a100798a5c14ed1bd8c2a1cd7bba6f1")
        SwiftyStoreKit.verifyReceipt(using: appeValidator) { (result) in
            
            switch result{
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: PRODUCT_ID, inReceipt: receipt)
                switch purchaseResult{
                case.purchased:
                    //リストア成功
                    self.count = 1
                    UserDefaults.standard.set(1, forKey: "buy")
                    break
                case .notPurchased:
                    //リストアされていない場合
                    
                    UserDefaults.standard.set(nil, forKey: "buy")
                    break
                    
                }
            case .error(let error):
                break
            }
        }
    }
    
    
    func checkImage(){
        Firestore.firestore().collection("メールアドレスと写真の紐付け").addSnapshotListener { (snapShot, error) in
            self.userInfo2 = []
            
            if error != nil{
               print(error.debugDescription)
               return
            }
        
           if let snapShotDoc = snapShot?.documents{
               
               for doc in snapShotDoc{
                   let data = doc.data()
                   
                   if let email = data["email"] as? String, let profileImage = data["profileImage"] as? String{

                       let newInfo = UserInfo2(email: email, profileImage: profileImage)
                       
                       self.userInfo2.append(newInfo)

                   }
               }
           }
            self.ccount = 0
            for i in 0...self.userInfo2.count - 1{
                if self.userInfo2[i].email == Auth.auth().currentUser?.email{
                    self.ccount = self.ccount + 1
                }
                
            }
            print("ccount")
            print(self.ccount)
            if self.ccount == 2{
                Firestore.firestore().collection("メールアドレスと写真の紐付け").document(self.docID).delete { (error) in
                    if error != nil{
                        print(error)
                    }else{
                        print("消したよ")
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
                                
        super.viewWillAppear(true)
        //ブログを読んだ数
        if UserDefaults.standard.object(forKey: "blogCount") != nil{
            bCount = UserDefaults.standard.object(forKey: "blogCount") as! Int
            blogCount.text = String(bCount)
        }
        //記事を見た数
        if UserDefaults.standard.object(forKey: "newsCount") != nil{
            nCount = UserDefaults.standard.object(forKey: "newsCount") as! Int
            articleCount.text = String(nCount)
        }        
        //動画を見た数
        if UserDefaults.standard.object(forKey: "movieCount") != nil{
            mCount = UserDefaults.standard.object(forKey: "movieCount") as! Int
            movieCount.text = String(mCount)
        }
        
    }
    
    @IBAction func editAccount(_ sender: Any) {
        //ログインしていないときだけ編集画面に遷移
        
            let accountVC = storyboard?.instantiateViewController(identifier: "account") as! accountViewController
            self.navigationController?.pushViewController(accountVC, animated: true)
        
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        
                
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userImage")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "movieCount")
        UserDefaults.standard.removeObject(forKey: "newsCount")
        UserDefaults.standard.removeObject(forKey: "blogCount")
        UserDefaults.standard.removeObject(forKey: "url")
        UserDefaults.standard.removeObject(forKey: "url2")
        UserDefaults.standard.removeObject(forKey: "MKA")
        UserDefaults.standard.removeObject(forKey: "face")
        UserDefaults.standard.removeObject(forKey: "title")
        UserDefaults.standard.removeObject(forKey: "body")
        
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            print("userを削除しました")
            
            let enterVC = storyboard?.instantiateViewController(identifier: "privacy") as! PrivacyViewController
            self.navigationController?.pushViewController(enterVC, animated: true)
        
        
    }
    
    func alert(string:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: "この機能の使用にはログインが必要です", message: string, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func removeAdv(_ sender: Any) {
        if Auth.auth().currentUser?.email != nil{
            purchase(PRODUCT_ID: "4323456543")
        }else{
            self.alert(string: "ログインは「設定」画面から可能です")
        }
        
    }
    @IBAction func contact(_ sender: Any) {
        let webViewControlle = WebViewController()
        let contact = "https://noifumi.com/NogizakaApp/contact.html"
        UserDefaults.standard.setValue(contact, forKey: "contact")
        present(webViewControlle, animated: true, completion: nil)
    }
    
    @IBAction func terms(_ sender: Any) {
        let webViewControlle = WebViewController()
        let terms = "https://noifumi.com/NogizakaApp/terms.html"
        UserDefaults.standard.setValue(terms, forKey: "terms")
        present(webViewControlle, animated: true, completion: nil)
    }
}
