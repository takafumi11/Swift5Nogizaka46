//
//  imageListViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2021/01/14.
//  Copyright © 2021 野入隆史. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import SDWebImage

class imageListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CatchUrlProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var URLArray = [String]()

    var arr = [String]()
    var arr3 = [String]()
    //二重配列を作る
    var arr2 = [[String]]()

    var memberName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        if UserDefaults.standard.object(forKey: "MEA") != nil{
            memberName = UserDefaults.standard.object(forKey: "MEA") as! String
        }
        //15記事分取得
        for i in 1...3{
            scrapeHTML(name: memberName, id: i)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
    }
    
    //dismissの時はリロードしない
    func catchUrlString(urlString: String) {
        if urlString != UserDefaults.standard.object(forKey: "MEA") as! String{
            arr3 = []
            memberName = UserDefaults.standard.object(forKey: "MEA") as! String
        }
        //15記事分取得
        for i in 1...3{
            scrapeHTML(name: memberName, id: i)
        }
    }
    
    func scrapeHTML(name:String,id:Int){
        //初期化しないと前のメンバーが残る

        URLArray = []
        arr = []
        arr2 = []

                      
        let url = "http://blog.nogizaka46.com/\(name)/?p=\(id)"
        
        AF.request(url).responseString { [self] (response) in
            if let html = response.value{
                if let doc = try? HTML(html:html , encoding: .utf8){
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
                    setArr()
                    tableView.reloadData()
                }
            }
        }
    }
    
    //一つの配列に戻す
    func setArr(){
        
        for j in 0...arr2.count - 1{
            for i in 0...arr2[j].count - 1{
                arr3.append(arr2[j][i])
            }
        }        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(ceil(Double(arr3.count/2)))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell",for: indexPath)
        
        let image1 = cell.contentView.viewWithTag(1) as! UIImageView
        let image2 = cell.contentView.viewWithTag(2) as! UIImageView

        var image1String:String = ""
        var image2String:String = ""
        
        if 2 * indexPath.row + 1 <= arr3.count - 1{
            image2String = arr3[2 * indexPath.row + 1]
            image1String = arr3[2 * indexPath.row]
        }else if 2 * indexPath.row <= arr3.count - 1{
            
            image1String = arr3[2 * indexPath.row]
        }
         

        if image1String != nil{
            image1.sd_setImage(with: URL(string:image1String), completed: { (image, error, _, _) in
                if error == nil{
                    cell.setNeedsLayout()
                }
            })
        }
        
        if image2String != nil{
            image2.sd_setImage(with: URL(string:image2String), completed: { (image, error, _, _) in
                if error == nil{
                    cell.setNeedsLayout()
                }
            })
        }

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeVC = storyboard?.instantiateViewController(identifier: "storeImage") as! StoreImageViewController
        storeVC.top = arr3[2 * indexPath.row + 1]
        storeVC.bottom = arr3[2 * indexPath.row]
        self.navigationController?.pushViewController(storeVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

