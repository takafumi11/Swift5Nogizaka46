//
//  ReadViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/31.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase

class ReadViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!

    var blogbody:String = ""
    var blogtitle:String = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        tableView.delegate = self
        tableView.dataSource = self
        
        if UserDefaults.standard.object(forKey: "title") != nil{
            blogtitle = UserDefaults.standard.object(forKey: "title") as! String
        }
        
        if UserDefaults.standard.object(forKey: "body") != nil{
            blogbody = UserDefaults.standard.object(forKey: "body") as! String
        }
               
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationBarが邪魔なので非表示
        navigationController?.isNavigationBarHidden = false
    }

    func trimming(string:String){
         string.trimmingCharacters(in: .whitespaces)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
    
        cell.textLabel?.text = blogbody
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .gray
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                                
        return cell
    }

}
