//
//  NewsViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/25.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SDWebImage
import Firebase
import ChameleonFramework
import GoogleMobileAds

class NewsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,CatchProtocol {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var titleArray = [String]()
    var textArray = [String]()
    var URLArray = [String]()
    var imageArray = [String]()        
              
    var newsModel:[NewsModel] = []
    
    var refresh = UIRefreshControl()
    
    var newsCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()                
        
        indicator.startAnimating()
        indicator.color = .purple
        tableView.delegate = self
        tableView.dataSource = self
        
        scrapeHTML()
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        //もしkey:"buy"なら購入済み
        //広告を排除
        if let buy = UserDefaults.standard.object(forKey: "buy"){
            let count = UserDefaults.standard.object(forKey: "buy") as! Int
            
            if count == 1{
//                bannerView.removeFromSuperview()
                print("購入されました")
            }
            
        }else{
            print("未購入")
            //広告を設定
            //テスト用コード
            bannerView.adUnitID = ""
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            //実機テスト用
//            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["41750c26f573911c710840f2825c844e"]
            
            //本番用はまだ
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.estimatedRowHeight = UIScreen.main.bounds.height
    }
    
    @objc func update(){
        tableView.reloadData()
        scrapeHTML()
        refresh.endRefreshing()
    }
    
    //protocol取得
    func catchData(count: Int) {
        if count == 1{
            bannerView.removeFromSuperview()
        }
    }
    
    //HTMLから情報取得
    func scrapeHTML(){
        let url = "https://news.yahoo.co.jp/search?p=%E4%B9%83%E6%9C%A8%E5%9D%82"
        
        AF.request(url).responseString { (response) in
            switch response.result{
                
                case .success(_):
                    if let html = response.value{
                        if let doc = try? HTML(html: html, encoding: .utf8){
                                                        
                            for titles in doc.css("div.newsFeed_item_title"){
                                let title = titles.text!
                                self.titleArray.append(title)
                                
                            }
                            
                            for link in doc.css("a.newsFeed_item_link"){
                                let links = link["href"]
                                self.URLArray.append(links!)
                                
                            }

                            for texts in doc.css("div.sc-folmNH"){
                                let text = texts.text!

                                self.textArray.append(text)
                                
                            }
                            
                            for images in doc.css("div.newsFeed_item_body img"){
                                let image = images["src"]
                                
                                self.imageArray.append(image!)
                                
                            }
                            
                            //class名の変更が結構あるので定期的にチェックする
//                            print(self.titleArray.count)
//                            print(self.URLArray.count)
//                            print(self.textArray.count)
//                            print(self.imageArray.count)
                            
                            for i in 0...self.titleArray.count-1{
                                var news = NewsModel(title: self.titleArray[i], thumbnail: self.imageArray[i], URL: self.URLArray[i])
                                self.newsModel.append(news)
                            }
                        }
                    }
                break
                    
                case .failure(let error):
                    print(error)
                break
            }
             DispatchQueue.main.async {
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.indicator.color = .clear
            }
        }
    }
        
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let index = newsModel[indexPath.row]
        let articleImage = URL(string: index.thumbnail)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.textLabel?.text = index.title
        cell.textLabel?.textColor = .black        
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        
        cell.imageView?.sd_setImage(with: articleImage, completed: { (image, error, _, _) in
            if error == nil{
                //これがないとおもおも
                cell.setNeedsLayout()
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webViewControlle = WebViewController()
        let url = newsModel[indexPath.row].URL
        
        newsCount = newsCount + 1
        UserDefaults.standard.set(newsCount, forKey: "newsCount")
        
        UserDefaults.standard.set(url, forKey: "url2")
        present(webViewControlle, animated: true, completion: nil)
    }

}
