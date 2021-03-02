//
//  RoomViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/12.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth


class RoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageModel:[MessageModel] = []
    var roomModel:[RoomModel] = []
    
    var memberKanjiArray:[String] = []
    
    var uuid = Auth.auth().currentUser?.uid
    var idString:String = Auth.auth().currentUser!.uid

    var imageString = String()
    var userName = String()
    var email = String()
        
    var ccount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser?.email == nil{
            let accountVC = storyboard?.instantiateViewController(identifier: "account") as! accountViewController
            self.navigationController?.pushViewController(accountVC, animated: true)
        }
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "email") != nil{
            email = UserDefaults.standard.object(forKey: "email") as! String
        }
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        }else{
            imageString = ""
        }
        
        if UserDefaults.standard.object(forKey: "MKA") != nil{
            memberKanjiArray = UserDefaults.standard.array(forKey: "MKA") as! [String]
            memberKanjiArray.append("")
        }
        
        print("情報")
        print(userName)
        print(email)
        print("\n")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .groupTableViewBackground
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadBlog()
        
    }
                    
    //room名を取得する(お気に入りに登録されているブログ)
    func loadBlog(){
                
        roomModel = []
        
        if Auth.auth().currentUser?.email != nil{
            let room = RoomModel(roomName: "\(userName)のメモ", roomImage: [imageString], updateDate: "", author: userName)
            roomModel.append(room)
        }else{
            let room = RoomModel(roomName: "この機能はログインしないと使えません", roomImage: [imageString], updateDate: "", author: userName)
            roomModel.append(room)
        }
        
        
        if memberKanjiArray.count > 1{
            for i in 0...memberKanjiArray.count-1{
                Firestore.firestore().collection("users").document(idString).collection("\(memberKanjiArray[i])のblog").addSnapshotListener { (snapShot, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                                    
                    if let snapShotDoc = snapShot?.documents{
                        for doc in snapShotDoc{
                            let data = doc.data()
                                                                            
                            if let title = data["title"] as? String,let url = data["url"] as? String,let body = data["body"] as? String,let imageString = data["imageString"] as? [String],let author = data["author"] as? String,let userName = data["userName"] as? String,let likeCount = data["like"] as? Int,let face = data["face"] as? String,let date = data["date"] as? String,let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>,let postDate = data["postDate"] as? NSNumber{
                                
                                //お気に入り登録しているもののみ取り出す
                                if likeFlagDic[self.idString] == true{
                                    
                                    let newroom = RoomModel(roomName: title, roomImage: imageString, updateDate: date, author: author)
                                    
                                    self.roomModel.append(newroom)
                                }
                            }
                        }
                    }
//                    print(self.roomModel)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell",for: indexPath)
        
        let roomImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let roomName = cell.contentView.viewWithTag(2) as! UILabel
        
        let author = cell.contentView.viewWithTag(4) as! UILabel
        

//        //これがないとindex out of range
        if roomModel.count >= ccount - 1{
//            print("\(roomModel.count)wwow")
            let index = roomModel[indexPath.row]
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
                                                                     
            let roomImage = URL(string: index.roomImage[0])
            roomImageView.sd_setImage(with:roomImage , completed: nil)
               
            roomName.text = index.roomName
            
            author.text = index.author
            ccount = roomModel.count
        }
        
        return cell
    }
           
    //chat画面に移動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //登録していないと移動できない
        if Auth.auth().currentUser?.email == nil{
            let accountVC = storyboard?.instantiateViewController(identifier: "account") as! accountViewController
            self.navigationController?.pushViewController(accountVC, animated: true)
        }
        if Auth.auth().currentUser?.email != nil{
            let chatVC = storyboard?.instantiateViewController(identifier: "chat") as! ChatViewController
            chatVC.roomName = roomModel[indexPath.row].roomName
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height/7
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomModel.count
    }
}


