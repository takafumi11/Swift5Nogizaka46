//
//  HistoryViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/13.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var youTubeModel:[YouTubeModel] = []
    
    var userName:String = ""
    
    var idString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        indicator.startAnimating()
        indicator.color = .purple
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        idString = Auth.auth().currentUser?.uid as! String
        
        tableView.register(UINib(nibName: "YouTubeCell", bundle: nil), forCellReuseIdentifier: "youTubeCell")
        
        loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func loadHistory(){
        
        youTubeModel = []
        
        Firestore.firestore().collection("users").document(idString).collection("YouTube").addSnapshotListener { (snapShot, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let url = data["url"] as? String,let publishedAt = data["publishedAt"] as? String,let title = data["title"] as? String,let thumbnail = data["thumbnail"] as? String{
                        
                        let newModel = YouTubeModel(URL: url, publishedAt: publishedAt, title: title, thumbnail: thumbnail)
                        self.youTubeModel.append(newModel)
                        
                    }
                }
            }
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            self.indicator.color = .clear
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return youTubeModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "youTubeCell",for: indexPath) as! YouTubeCell
        let index = youTubeModel[indexPath.row]
        let thumbnail = URL(string: index.thumbnail)
        
        tableView.rowHeight = 300
        
        cell.titleLabel.text = index.title
        cell.postDateLabel.text = index.publishedAt
        cell.thumbnailView?.sd_setImage(with: thumbnail, completed: { (image, error, _, _) in
            if error == nil{
                cell.setNeedsLayout()
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webViewControlle = WebViewController()
        
        let index = youTubeModel[indexPath.row]
        
        UserDefaults.standard.set(index.URL, forKey: "url")
        self.present(webViewControlle, animated: true, completion: nil)
            
    
    }

}
