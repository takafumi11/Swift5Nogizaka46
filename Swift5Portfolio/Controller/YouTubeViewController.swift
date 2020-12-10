//
//  YouTubeViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/18.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class YouTubeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
       
    @IBOutlet weak var tableView: UITableView!
    
//    var videoIDArray = [String]()
//    var publishedAtArray = [String]()
//    var titleArray = [String]()
//    var imageURLArray = [String]()
//    var youTubeURLArray = [String]()
    
    var youTubeModel:[YouTubeModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
    }
    
    
    //YouTubeData取得
    func getData(){
        var urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyBE1F2OgjddryJQ85jiGFVzSrRKx_vn42I&q=乃木坂46&part=snippet&maxResults=20&order=date"
        
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        
        
        AF.request(url as! URLConvertible, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            print(response)
            
            switch response.result{
            case .success(_):
                for i in 0...19{
                    let json = JSON(response.data)
                    let videoId = json["items"][i]["id"]["videoId"].string
                    let publishedAt = json["items"][i]["snippet"]["publishedAt"].string
                    let title = json["items"][i]["snippet"]["title"].string
                    let thumbnail = json["items"][i]["snippet"]["thumbnails"]["default"]["url"].string
                    //これはwebViewに使う
                    let youtubeURL = "https://www.youtube.com/watch?v=\(videoId!)"
                    
                    var YTModel = YouTubeModel(URL: youtubeURL, publishedAt: publishedAt!, title: title!, thumbnail: thumbnail!)
                    self.youTubeModel.append(YTModel)
                    
                }
            break
            
            case .failure(let error):
                print(error)
                break
            }
            self.tableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return youTubeModel.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 3
        
        let index = youTubeModel[indexPath.row]
        
        let thumbnailURL = URL(string: index.thumbnail)
        
        cell.imageView?.sd_setImage(with: thumbnailURL, completed: nil)
        cell.textLabel?.text = index.title
        cell.detailTextLabel?.text = index.publishedAt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webViewControlle = WebViewController()
        let url = youTubeModel[indexPath.row].URL
        
        UserDefaults.standard.set(url, forKey: "url")
        present(webViewControlle, animated: true, completion: nil)
    }

}
