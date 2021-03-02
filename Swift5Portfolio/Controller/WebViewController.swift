//
//  WebViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/24.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import WebKit
import Firebase


class WebViewController: UIViewController {
    
    var webView = WKWebView()
    
    var count:Int = 0
    
    var indicator = UIActivityIndicatorView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
                
        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(webView)
        
//        indicator.startAnimating()
//        indicator.color = .purple
//        indicator.style = .large
//        indicator.center = webView.center
//        self.webView.addSubview(indicator)
        
        //YouTube
        if UserDefaults.standard.object(forKey: "url") != nil{
            let urlString = UserDefaults.standard.object(forKey: "url")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "url")
            
            webView.load(request)
        }
        
        //News
        if UserDefaults.standard.object(forKey: "url2") != nil{
            let urlString = UserDefaults.standard.object(forKey: "url2")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "url2")
            
            webView.load(request)
        }
        
        //contact
        if UserDefaults.standard.object(forKey: "contact") != nil{
            let urlString = UserDefaults.standard.object(forKey: "contact")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "contact")
            
            webView.load(request)
        }
        
        //terms
        if UserDefaults.standard.object(forKey: "terms") != nil{
            let urlString = UserDefaults.standard.object(forKey: "terms")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "terms")
            
            webView.load(request)
        }
//
//        self.indicator.stopAnimating()
//        indicator.color = .clear
        
    }
    
}
