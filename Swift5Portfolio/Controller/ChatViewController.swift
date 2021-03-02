//
//  ChatViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/31.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
            
    var messageModel:[MessageModel] = []
    
    var imageString:String = ""
    var userName:String = ""
    var roomName:String = ""
    var idString:String = ""
    
    var refresh = UIRefreshControl()
    
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        }
        
        idString = Auth.auth().currentUser!.uid
        
        print("\(roomName)roomname")
        
        getMessage(roomName: roomName)
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func update(){
        tableView.reloadData()
        refresh.endRefreshing()
    }
                  
    func getMessage(roomName:String){
        let date = Date()
        let formatter = DateFormatter()
        let nowDate = formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
 
        //個人メモの場合
        let suf = roomName.suffix(2)
        
        if suf == "メモ"{
            Firestore.firestore().collection("users").document(idString).collection("\(roomName)").order(by: "date2").addSnapshotListener { (snapShot, error) in
                self.messageModel = []
                if error != nil{
                    print(error.debugDescription)
                    return
                }
     
                if let snapShotDoc = snapShot?.documents{
                    
                    for doc in snapShotDoc{
                        let data = doc.data()
                        
                        if let email = data["email"] as? String, let sender = data["sender"] as? String,let body = data["body"] as? String,let imageString = data["imageString"] as? String,let date = data["date"] as? String{

                            let newMessage = MessageModel(sender: sender, body: body, imageString: imageString, email: email, date:date)
                            
                            self.messageModel.append(newMessage)

                        }
                    
                        //一番下までスクロール
                        DispatchQueue.main.async {
                           self.tableView.reloadData()
                           let indexPath = IndexPath(row: self.messageModel.count - 1, section: 0)
                           self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }else{
            Firestore.firestore().collection("chats").document("1qaz2wsx3edc4rfv").collection("\(roomName)").order(by: "date2").addSnapshotListener { (snapShot, error) in
                self.messageModel = []
                if error != nil{
                    print(error.debugDescription)
                    return
                }
     
                if let snapShotDoc = snapShot?.documents{
                    
                    for doc in snapShotDoc{
                        let data = doc.data()
                        
                        if let email = data["email"] as? String, let sender = data["sender"] as? String,let body = data["body"] as? String,let imageString = data["imageString"] as? String,let date = data["date"] as? String{

                            let newMessage = MessageModel(sender: sender, body: body, imageString: imageString, email: email, date:date)
                            
                            self.messageModel.append(newMessage)

                        }
                    
                        //一番下までスクロール
                        DispatchQueue.main.async {
                           self.tableView.reloadData()
                           let indexPath = IndexPath(row: self.messageModel.count - 1, section: 0)
                           self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
        
    }
        
    //匿名ログインの時は使えなくしよう!!
    @IBAction func send(_ seder :Any) {
        if let email = Auth.auth().currentUser?.email, let messageBody = messageTextField.text, let sender = userName as? String{
            //表示用
            let date = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let nowDate = formatter.string(from: date)
            //並び替え用
            let nowDate2 = Date().timeIntervalSince1970
            
            //個人メモの場合
            let suf = roomName.suffix(2)
              
            if suf == "メモ"{
                Firestore.firestore().collection("users").document(idString).collection(roomName).addDocument(data: ["email":email,"sender":sender,"body":messageBody,"imageString":imageString,"date":nowDate,"date2":nowDate2]) { (error) in
                   if error != nil{
                       print(error.debugDescription)
                       return
                   }
                }
            }else{
                Firestore.firestore().collection("chats").document("1qaz2wsx3edc4rfv").collection(roomName).addDocument(data: ["email":email,"sender":sender,"body":messageBody,"imageString":imageString,"date":nowDate,"date2":nowDate2]) { (error) in
                   if error != nil{
                       print(error.debugDescription)
                       return
                   }
                }
            }
            
            //非同期処理
            DispatchQueue.main.async {
                self.messageTextField.text = ""
                self.messageTextField.resignFirstResponder()
            }
            
        }
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell",for: indexPath) as! MessageCell
                
        let index = messageModel[indexPath.row]
        
        
        
        cell.messageTextLabel.text = index.body
        cell.messageTextLabel.numberOfLines = 3
        cell.myMessageTextLabel.text = index.body
        cell.myMessageTextLabel.numberOfLines = 3
        cell.sender.text = index.sender
        
        let profileImage = URL(string: index.imageString)
        cell.profileImageView?.sd_setImage(with: profileImage, completed: { (image, error, _, _) in
            if error == nil{
                cell.setNeedsLayout()
            }
        })
        
        cell.backGroungView.layer.cornerRadius = 20.0

        //送信者が自分の時
        if index.sender == userName{
            cell.profileImageView.isHidden = true
            cell.messageTextLabel.textAlignment = .right            
            cell.backGroungView.backgroundColor = .green
            cell.sender?.isHidden = true
            tableView.rowHeight = 90
            cell.messageTextLabel.isHidden = true
            cell.backGroungView.layer.cornerRadius = 15.0
            cell.myTimeLabel.text = index.date
            cell.opponentTimeLabel.isHidden = true

        }else{

            tableView.rowHeight = 120
            cell.messageTextLabel.textAlignment = .left
            cell.backGroungView?.backgroundColor = .white
            cell.myMessageTextLabel.isHidden = true
            cell.backGroungView.layer.cornerRadius = 20.0
            cell.opponentTimeLabel.text = index.date
            cell.myTimeLabel.isHidden = true
            
        }
        
                                
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageModel.count
    }
}


