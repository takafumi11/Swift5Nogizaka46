//
//  LikeViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/05.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class LikeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var blogModel:[BlogModel] = []
    
    var blogTitle = ""
    var author = ""
    var idString:String = Auth.auth().currentUser!.uid
    
    var memberKanjiArray:[String] = []
    
    var userName = ""
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        indicator.startAnimating()
        indicator.color = .purple
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "title") != nil{
            blogTitle = UserDefaults.standard.object(forKey: "title") as! String
        }
        
        if UserDefaults.standard.object(forKey: "MKA") != nil{
            memberKanjiArray = UserDefaults.standard.array(forKey: "MKA") as! [String]
            memberKanjiArray.append("")
        }
        
         tableView.register(UINib(nibName: "BlogCell", bundle: nil), forCellReuseIdentifier: "blogCell")
        
        view.backgroundColor = .groupTableViewBackground
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        loadBlog()
    }
    
   func loadBlog(){
        
        blogModel = []
        
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
                            print("\(likeFlagDic[self.idString])\(self.memberKanjiArray[i])qqq")
                            //お気に入り登録しているもののみ取り出す
                            if (likeFlagDic[self.idString])! == true{
                                print("uioixr")
                                let blog = BlogModel(title: title, body: body, imageString: imageString, url: url, date: date, author: author, userNmae: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic, face: face, postDate: postDate)
                                self.blogModel.append(blog)
                                                            
                            }
                        }
                    }
                }
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.indicator.color = .clear
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "blogCell",for: indexPath) as! BlogCell
                     
        tableView.rowHeight = 391
                          
        let index = blogModel[indexPath.row]
         
        let faceImage = URL(string: index.face)
        let blogImage = URL(string: index.imageString[0])
                                 
        cell.blogTitle.text = index.title
        cell.author.text = index.author
        cell.likeCount.text = String(index.likeCount)
        cell.upDate.text = index.date
        cell.likeBtn.isHidden = true
                                 
        cell.face.sd_setImage(with: faceImage, completed: nil)
        //ブログに写真が使われている場合
        if index.imageString[0] != ""{
             cell.blogImageView?.sd_setImage(with: blogImage, completed: { (image, error, _, _) in
                 if error == nil{
                     cell.setNeedsLayout()
                 }
             })
            print("imagestring")
            print(index.imageString[0])
        }else if index.imageString[0] == ""{
             cell.blogImageView?.sd_setImage(with: faceImage, completed: { (image, error, _, _) in
                 if error == nil{
                     cell.setNeedsLayout()
                 }
             })
        }
                     
        cell.blogTitle.numberOfLines = 3
                
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        cell.bgView.layer.cornerRadius = 20.0
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blogtitle = blogModel[indexPath.row].title
//        let url = blogModel[indexPath.row].url
        let blogBody = blogModel[indexPath.row].body
        
        UserDefaults.standard.set(blogtitle, forKey: "title")
        UserDefaults.standard.set(blogBody, forKey: "body")
        
        let readVC = storyboard?.instantiateViewController(identifier: "read") as! ReadViewController
        self.navigationController?.pushViewController(readVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogModel.count
    }

}
