//
//  YouTubeViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/18.
//  Copyright © 2020 野入隆史. All rights reserved.


import UIKit
import Firebase
import FirebaseFirestore
import Alamofire
import SwiftyJSON
import SDWebImage
import FirebaseAuth

class YouTubeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
       
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
        
    
    var youTubeModel:[YouTubeModel] = []
    
    var userName:String = ""
    
    var movieCount:Int = 0
    
    var idString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        
        if searchTextField.text == ""{
            getData(word: "乃木坂")
        }
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        view.backgroundColor = .groupTableViewBackground
        
        idString = Auth.auth().currentUser?.uid as! String
        
        tableView.register(UINib(nibName: "YouTubeCell", bundle: nil), forCellReuseIdentifier: "youTubeCell")
        
        indicator.startAnimating()
        indicator.color = .purple
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
                
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
    
    //JSONでData取得
    func getData(word:String){
        youTubeModel = []
        var urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyBKViS7HDsxSgBCEBQB288EopoUDq3-rxU&q=\(word)&part=snippet&maxResults=20&order=date"
        
//        var urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyBKViS7HDsxSgBCEBQB288EopoUDq3-rxU&q=乃木坂46MV&part=snippet&maxResults=20&order=relevance&type=playlist"
//        var urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyBKViS7HDsxSgBCEBQB288EopoUDq3-rxU&q=乃木坂46MV&part=snippet&channelId=UCUzpZpX2wRYOk3J8QTFGxDg&maxResults=20&order=date&type=movie"
//        var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyBKViS7HDsxSgBCEBQB288EopoUDq3-rxU&part=snippet&playlistId=PLDUMgL1jIEfMcaJcz082WS8TxcTlexJKz&pageToken="
        
        
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
        AF.request(url as! URLConvertible, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { [self] (response) in
            print(response)
            
            switch response.result{
            case .success(_):
                for i in 0...20{
                    
                    if var json:JSON = JSON(response.data) as? JSON{
                        if let videoId = json["items"][i]["id"]["videoId"].string,let publishedAt = json["items"][i]["snippet"]["publishedAt"].string,let title = json["items"][i]["snippet"]["title"].string,let thumbnail = json["items"][i]["snippet"]["thumbnails"]["medium"]["url"].string{
                            
                            let youtubeURL = "https://www.youtube.com/watch?v=\(videoId)"
                            
                            var YTModel = YouTubeModel(URL: youtubeURL, publishedAt: publishedAt, title: title, thumbnail: thumbnail)
                            self.youTubeModel.append(YTModel)
                        }
                    }                    
                }
            break

            case .failure(let error):
                print(error)
                break
            }
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            self.indicator.color = .clear
        }
    }
        
    @IBAction func search(_ sender: Any) {
        if searchTextField.text != nil{
            getData(word: searchTextField.text!)
        }
        searchTextField.text = ""
    }
    
    //履歴チェック
    @IBAction func history(_ sender: Any) {
        if Auth.auth().currentUser?.email != nil{
            let hisVC = storyboard?.instantiateViewController(identifier: "history") as! HistoryViewController
            self.navigationController?.pushViewController(hisVC, animated: true)
        }else{
            self.alert(string: "ログインは「設定」画面から可能です")
        }
    }                
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "youTubeCell",for: indexPath) as! YouTubeCell
        
        tableView.rowHeight = 300
    
        let index = youTubeModel[indexPath.row]
        cell.titleLabel.text = index.title
        cell.titleLabel.numberOfLines = 2
        cell.postDateLabel.text = index.publishedAt
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let thumbnailURL = URL(string: index.thumbnail)
        cell.thumbnailView.sd_setImage(with: thumbnailURL, completed: { (image, error, _, _) in
            if error == nil{                
                cell.setNeedsLayout()
            }
        })
        return cell
    }
    
    func alert(string:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: "この機能の使用にはログインが必要です", message: string, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webViewControlle = WebViewController()
        
        let index = youTubeModel[indexPath.row]
        
        movieCount = movieCount + 1
        
        UserDefaults.standard.set(movieCount, forKey: "movieCount")
        
        //匿名の場合も履歴に保存はされるけど後から見れない
        Firestore.firestore().collection("users").document(idString).collection("YouTube").addDocument(data: ["title":index.title,"thumbnail":index.thumbnail,"url":index.URL,"publishedAt":index.publishedAt]) { (error) in
            if error != nil{
                print(error.debugDescription)
            }
            //DBに保存できたら画面遷移
            UserDefaults.standard.set(index.URL, forKey: "url")
            self.present(webViewControlle, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return youTubeModel.count
    }
}
