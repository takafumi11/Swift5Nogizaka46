//
//  BlogViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/31.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class BlogViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
        
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var pickerView = UIPickerView()
    
    var blogModel:[BlogModel] = []
    var likeModel:[LikeModel] = []
    
    var docIDArray = [String]()
        
    var titleArray = [String]()
    var URLArray = [String]()
    var bodyArray = [String]()
    var dateArray = [String]()
    var authorArray = [String]()
    
    var memberKanjiArray = [String]()
    var memberEngArray = [String]()
    var faceArray = [String]()
    
    //初期値は空にして記事一覧を表示させる
    var memberName = ""
    var userName = ""
    var email = ""
    
    var author = ""
        
    var idString:String = ""
    var docID = ""
    
    //ブログの写真を取得する
    var cnt = -1
    var arr = [String]()
    //二重配列を作る
    var arr2 = [[String]]()
    
    //db追加のcheck
    var checkArray = [String]()
    
    var deltaT:Double = 0
    
    var cccount = 0
    
    var blogCount = 0
    
    var likesCount = 0
    
    
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //これがないと通知を受け取れない
        let authOption:UNAuthorizationOptions = [.alert,.badge,.sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOption) { (_, _) in
            print("プッシュ通知許可画面OK")
        }
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "email") != nil{
            email = UserDefaults.standard.object(forKey: "email") as! String
        }
        
        indicator.startAnimating()
        indicator.color = .purple
        
        tableVIew.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
                                
        idString = Auth.auth().currentUser?.uid as! String
                                
        //pickerの設定
        memberTextField.inputView = pickerView
        
        
        //ここをどうにかして更新させないようにしたい
        if blogModel.count == 0{
            //画面を開いた瞬間にKnnna取得
            scrapeHTML(name: memberName as! String, id: 1)
            //一回呼べばOK
            getName()
        }
                                       
        tableVIew.delegate = self
        tableVIew.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //CustomCellの設定
        tableVIew.register(UINib(nibName: "BlogCell", bundle: nil), forCellReuseIdentifier: "blogCell")
        
        //アカウントのログイン記録をFirestoreに保存
        loginHistory()
               
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        if UserDefaults.standard.object(forKey: "blogCount") != nil{
            blogCount = UserDefaults.standard.object(forKey: "blogCount") as! Int
        }
    }
    
    @IBAction func goImageList(_ sender: Any) {
        if memberTextField.text  == ""{
            self.alert2(string: "「全メンバー一覧」からメンバーを選択しよう!!")
        }else{
            let listVC = storyboard?.instantiateViewController(identifier: "imageList") as! imageListViewController
            self.navigationController?.pushViewController(listVC, animated: true)
        }
    }
    
    @objc func update(){
        tableVIew.reloadData()        
        refresh.endRefreshing()
    }
    
    func loginHistory(){
        
        let formatter = DateFormatter()
        let nowDate = formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //表示用
        let date = Date()
        formatter.timeStyle = .short
        let nowDate2 = formatter.string(from: date)
        
        Firestore.firestore().collection("ログイン記録").document().setData(["id":idString,"email":Auth.auth().currentUser?.email,"date":nowDate2,"sinceInterval":Date().timeIntervalSince1970]) { (error) in
            if error != nil{
                print(error)
                return
            }
            
            print(Auth.auth().currentUser?.displayName)
        }
    }
    
    //ブログ記事時取得
    func scrapeHTML(name:String,id:Int){
        //初期化しないと前のメンバーが残る
        titleArray = []
        bodyArray = []
        URLArray = []
        arr = []
        arr2 = []
        authorArray = []
        dateArray = []
        cccount = 0
                      
        let url = "http://blog.nogizaka46.com/\(name)/?p=\(id)"
        
        AF.request(url).responseString { (response) in
            if let html = response.value{
                if let doc = try? HTML(html:html , encoding: .utf8){
                                                
                    //ブログのタイトルとURLを取得
                    for title in doc.css("span.heading span.entrytitle a"){
                        
                        let titles = title.text!
                        let urls = title["href"]!

                        self.titleArray.append(titles)
                        self.URLArray.append(urls)
                    }
                    
                    for date in doc.css("span.date"){
                        let dates = date.text!

                        let from = dates.index(dates.startIndex, offsetBy:0)
                        let to = dates.index(dates.startIndex, offsetBy:dates.count-3)
                        let newString = String(dates[from..<to])
                        
                        //Monみたいに曜日も取得してしまうので最後の三文字を削除
                        self.dateArray.append(newString)
                    }
                    
                    //author取得
                    for author in doc.css("span.author"){
                        let authors = author.text!
                        
                        self.authorArray.append(authors)
                    }
                    
                   //ブログの中身(文章を)取得
                    //公式のブログは改行やスペースが多すぎるので削除
                    for body in doc.css("div.entrybody"){
                        
                        let bodies = body.text!
                        let newBodies = bodies.filter { !$0.isNewline}
                        
                        self.bodyArray.append(newBodies)
//                            print("\(newBodies)body\n")
                    }
                    
                    //顔写真取得
                    for face in doc.css("div.pic img"){
                        let faces = face["src"]
//                            self.faceArray.append(faces!)
                        UserDefaults.standard.set(faces, forKey: "face")
                        
                    }
                    var aaa = ""
                    
                    for pic in doc.css("div.entrybody img"){
                        let pics = pic["src"]
                        let suf = pics?.suffix(2)
                        
                        var newString:String = ""
                                   
                        var ssl = ""
                        
                        //拡張子がjpgの場合
                        if suf == "pg"{
                            let from = pics!.index(pics!.startIndex, offsetBy:pics!.count-16)
                            let to = pics!.index(pics!.startIndex, offsetBy:pics!.count-9)
                            newString = String(pics![from..<to])
                            ssl = "https"
                        //拡張子がjpegの場合
                        }else if suf == "eg"{
                            let from = pics!.index(pics!.startIndex, offsetBy:pics!.count-17)
                            let to = pics!.index(pics!.startIndex, offsetBy:pics!.count-10)
                            newString = String(pics![from..<to])
                            ssl = "https"
                        }
                        else{
                            let from = pics!.index(pics!.startIndex, offsetBy:1)
                            let to = pics!.index(pics!.startIndex, offsetBy:5)
                            newString = String(pics![from..<to])
                            ssl = newString
                        }
                                   
                        //imagタグなのに公式のバグで写真が入っていない場合がある
                        if pics != nil && ssl == "https"{
//                                print(pics!)

                            if aaa == ""{
                                aaa = newString
                            }

                            if aaa == newString{
                                self.arr.append(pics!)
                            }else{

                                self.arr2.append(self.arr)
                                self.arr = []
                                self.arr.append(pics!)
                                aaa = newString
                            }
                        }
                    }

                    self.arr2.append(self.arr)

                    //ブログ表示用に空白を入れている。
                    for i in 0...5{
                        if self.arr2.count < 5{
                            self.arr2.append([""])
                        }
                    }
                }
            }
            self.storeBlog()
        }
    }
        
    
    //漢字表記・英語表記の名前取得
    func getName(){
        let url = "http://blog.nogizaka46.com/"
        AF.request(url).responseString { (response) in
            if let html = response.value{
                if let doc = try? HTML(html: html, encoding: .utf8){
                    
                    //英語表記で取得
                    for link in doc.css("div.unit a"){
                        //取得するときに邪魔なものが入ってしまうので/の後を抽出
                        let links = link["href"]
                        let idx1 = links?.index(of: "/")
                        let idx2 = links?.index(after: idx1!)
                        let name = links![idx2!...]
                        
                        self.memberEngArray.append(String(name))
                    }
                    //漢字表記で取得
                    for name in doc.css("span.kanji"){
                        let names = name.text
                        self.memberKanjiArray.append(names!)
                        UserDefaults.standard.set(self.memberKanjiArray, forKey: "MKA")
                    }
                }
            }
        }
    }
    
        
    //textFieldと配列の照合をして選択したメンバーにチェンジする
    func selectMember(){
        for i in 0...memberKanjiArray.count-1{
            if memberTextField.text == memberKanjiArray[i]{
                memberName = memberEngArray[i]
                UserDefaults.standard.setValue(memberEngArray[i], forKey: "MEA")
            }
        }
        
    }
    
    func alert(string:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: "この機能の使用にはログインが必要です", message: string, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }
    
    func alert2(string:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: "この機能の使用にはメンバーの選択が必要です", message: string, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }
    
    //Firestoreにデータ保存
    func storeBlog(){
        
        docIDArray = []
        
        for i in 0...titleArray.count-1{
            let docid = Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document().path
            let from = docid.index(docid.startIndex, offsetBy:docid.count-20)
            let to = docid.index(docid.startIndex, offsetBy:docid.count)
            let newString = String(docid[from..<to])
            
            //ここで取得しておかないと後で書き換えるときにdocumentの指定ができない
            docID = newString

            //firestore登録
            Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document(docID).setData(["title":titleArray[i],"url":URLArray[i],"body":bodyArray[i],"imageString":arr2[i],"date":dateArray[i],"author":authorArray[i],"face":UserDefaults.standard.object(forKey: "face"),"userName":userName,"postDate":Date().timeIntervalSince1970,"like":0,"likeFlagDic":[idString:false]])
                        
            docIDArray.append(docID)
        }
                    
//        //一旦全部取り出して新しく入れたブログと元々あったブログが一致していたら今入れた方を消す
        Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.blogModel = []

            if error != nil{
                print(error.debugDescription)
                return
            }

            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let title = data["title"] as? String,let url = data["url"] as? String,let body = data["body"] as? String,let imageString = data["imageString"] as? [String],let author = data["author"] as? String,let date = data["date"] as? String,let userName = data["userName"] as? String,let face = data["face"] as? String,let likeCount = data["like"] as? Int,let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>,let postDate = data["postDate"] as? NSNumber{
                        let blog = BlogModel(title: title, body: body,imageString:imageString,url:url, date: date, author: author, userNmae: userName, docID: doc.documentID, likeCount:likeCount, likeFlagDic: likeFlagDic, face: face, postDate: postDate)
                            self.blogModel.append(blog)
                    }
                }
            }
            //4以下にしてしまうと一番最初に入れた瞬間にも消してしまう

            if self.blogModel.count > 5{

                for i in 0...self.titleArray.count-1{
                    self.checkArray.append(self.titleArray[i])
                }

                for i in 0...self.blogModel.count-1{
                    self.checkArray.append(self.blogModel[i].title)
                }

                for j in 0...self.titleArray.count-1{
                    var counttt = 0
                    for i in 0...self.checkArray.count-1{
                        if self.checkArray[i].contains(self.titleArray[j]){
                            counttt = counttt + 1
                        }
                    }

                    //今入れたブログのタイトルと元々入っていたブログのタイトルが一致している時、countt == 3になる。
                    if counttt == 3{
                        Firestore.firestore().collection("users").document(self.idString).collection("\(self.memberTextField.text!)のblog").document(self.docIDArray[j]).delete { (error) in
                            if error != nil{
                                print(error)
                            }else{
                                print("消したよ")
                            }
                        }
                    }
                }

            }
            self.tableVIew.reloadData()
            self.indicator.stopAnimating()
            self.indicator.color = .clear
        }
        addStruct()
    }

    //表示する用に構造体にも入れる
    func addStruct(){
        Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.blogModel = []
           
            if error != nil{
                print(error.debugDescription)
                return
            }

            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let title = data["title"] as? String,let url = data["url"] as? String,let body = data["body"] as? String,let imageString = data["imageString"] as? [String],let author = data["author"] as? String,let date = data["date"] as? String,let userName = data["userName"] as? String,let face = data["face"] as? String,let likeCount = data["like"] as? Int,let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>,let postDate = data["postDate"] as? NSNumber {
                        let blog = BlogModel(title: title, body: body,imageString:imageString, url: url, date: date, author: author, userNmae: userName, docID: doc.documentID, likeCount:likeCount, likeFlagDic: likeFlagDic, face: face, postDate: postDate)
                        self.blogModel.append(blog)
                    }
                }
            }
            
            self.sortTime()
            
            self.tableVIew.reloadData()
        }
    }

    func sortTime(){
        //現在時間と追加当時の時間差を求める
        
        if blogModel.count > 1{
            self.deltaT = Double(self.blogModel[self.blogModel.count-1].postDate) - Double(self.blogModel[0].postDate)
            //postDateを書き換えてtableViewの並び替えをする
            //現状のままだと新しい投稿にもかかわらず表示されない
            if self.blogModel.count > 5 && self.cccount == 0 {
                
                for i in 0...self.blogModel.count-1{
                    if Double(self.blogModel[i].postDate) < Double(self.blogModel[self.blogModel.count-1].postDate)-1{
                        Firestore.firestore().collection("users").document(idString).collection("\(self.memberTextField.text!)のblog").document(self.blogModel[i].docID).updateData(["postDate": NSNumber(value: Double(self.blogModel[i].postDate) + self.deltaT + 0.0001)])

                        self.cccount = 1
                    }
                }
            }
        }
    }
    
    //chat用のDBに入れる
    func addLikeStruct(){
            
        likeModel = []
        
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
                                        print("\(likeFlagDic[self.idString])\(self.memberKanjiArray[i])")
                                        //お気に入り登録しているもののみ取り出す
                                        if likeFlagDic[self.idString] == true{
                                            
                                            let newLike = LikeModel(title: title, body: body, imageString: imageString, url: url, date: date, author: author, userNmae: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic, face: face, postDate: postDate)
                                            
                                            self.likeModel.append(newLike)
                                                                            
                                        }
                                    }
                                }
                            }
                            self.addLikeDB()            
                        }
                    }
        }
        
    }
//
    func addLikeDB(){
        for i in 0...likeModel.count-1{
            Firestore.firestore().collection("users").document(idString).collection("\(userName)のlike").addDocument(data: ["title":likeModel[i].title,"author":likeModel[i].author,"imageString":likeModel[i].imageString]) { (error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
            }
        }

    }
    

    @objc func tapBtn(_ btn: UIButton){
        
        //登録していないと使えない機能
        if Auth.auth().currentUser?.email == nil{
            self.alert(string: "ログインは「設定」画面から可能です")
            
        }else{
            let flag = self.blogModel[btn.tag].likeFlagDic[idString]
            //        print(blogModel[btn.tag].docID)
                        
            if flag == nil{
                likesCount = self.blogModel[btn.tag].likeCount + 1
                Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document(blogModel[btn.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
            }else{
                if flag! as! Bool == true{
                    print("2")
                    likesCount = self.blogModel[btn.tag].likeCount - 1
                    Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document(blogModel[btn.tag].docID).setData(["likeFlagDic":[idString:false]], merge: true)
                    
                    
                }else{
                    print("3")
                    Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document(blogModel[btn.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
                    likesCount = self.blogModel[btn.tag].likeCount + 1
                    
                }
            }
            Firestore.firestore().collection("users").document(idString).collection("\(memberTextField.text!)のblog").document(blogModel[btn.tag].docID).updateData(["like":likesCount], completion: nil)
        }        

    }
                
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blogCell",for: indexPath) as! BlogCell
                
        tableView.rowHeight = 391
        
        if blogModel.count > 4{
            let index = blogModel[indexPath.row]
            
            let faceImage = URL(string: UserDefaults.standard.object(forKey: "face") as! String)
            let blogImage = URL(string: index.imageString[0])
                                    
            cell.blogTitle.text = index.title
            cell.author.text = index.author
            cell.likeCount.text = String(index.likeCount)
            cell.upDate.text = index.date
                                    
            cell.face.sd_setImage(with: faceImage, completed: nil)
            //ブログに写真が使われている場合
            if index.imageString[0] != ""{
                cell.blogImageView?.sd_setImage(with: blogImage, completed: { (image, error, _, _) in
                    if error == nil{
                        //これがないとおもおも
                        cell.setNeedsLayout()
                    }
                })
            }else if index.imageString[0] == ""{
                cell.blogImageView?.sd_setImage(with: faceImage, completed: { (image, error, _, _) in
                    if error == nil{
                        //これがないとおもおも
                        cell.setNeedsLayout()
                    }
                })
            }
                        
            cell.blogTitle.numberOfLines = 3
            
            cell.likeBtn.tag = indexPath.row
            cell.likeBtn.addTarget(self, action: #selector(tapBtn(_: )), for: UIControl.Event.touchUpInside)
   
        }
                
        //これでセルをタップ時、色は変化しなくなる
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        cell.bgView.layer.cornerRadius = 20.0
                
        //お気に入りリストに自分が入っている場合
        if self.blogModel.count > 4{
            if (self.blogModel[indexPath.row].likeFlagDic[idString] != nil) == true{
               let flag = self.blogModel[indexPath.row].likeFlagDic[idString]
                //お気に入りに追加していればlikeの写真、そうでなければnolike
                if flag! as! Bool == true{
                    cell.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                }else{
                    cell.likeBtn.setImage(UIImage(named: "noLike"), for: .normal)
                }
            }
        }
                
        return cell
    }
                        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let blogtitle = blogModel[indexPath.row].title
        let blogBody = blogModel[indexPath.row].body
        
        UserDefaults.standard.set(blogtitle, forKey: "title")
        UserDefaults.standard.set(blogBody, forKey: "body")
                    
        //ブログを読んだ数記録
        blogCount = blogCount + 1
        UserDefaults.standard.set(blogCount, forKey: "blogCount")
        
        let readVC = storyboard?.instantiateViewController(identifier: "read") as! ReadViewController
        self.navigationController?.pushViewController(readVC, animated: true)
        
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
        
    //pickView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return memberKanjiArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        memberTextField.text = memberKanjiArray[row]
        memberTextField.resignFirstResponder()
                
        //スクロースが決定したら記事再取得
        selectMember()
        scrapeHTML(name: memberName, id: 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return memberKanjiArray[row]
    }

    //お気に入り画面に移動
    @IBAction func like(_ sender: Any) {                
        let likeVC = storyboard?.instantiateViewController(identifier: "like") as! LikeViewController
        self.navigationController?.pushViewController(likeVC, animated: true)
    }    
}




        
  
    
    
