//
//  PrivacyViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/30.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController,WKNavigationDelegate {
    
    var webView = WKWebView()
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        indicator.startAnimating()
        indicator.color = .purple
        
        webView.frame = CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height - agreeLabel.frame.size.height - agreeBtn.frame.size.height * 2)
        
        view.addSubview(webView)
        
                
        webView.navigationDelegate = self
        
        let url = URL(string: "https://noifumi.com/NogizakaApp/terms.html")
        
        let request = URLRequest(url: url!)
        
        webView.load(request)
        self.indicator.stopAnimating()
        self.indicator.color = .clear
        
        
        CheckBtnDidTap()

    }
    
    
    func CheckBtnDidTap(){
        if (self.checkBtn.isSelected){
            self.agreeBtn.layer.backgroundColor = UIColor(red: 163/255, green: 32/255, blue: 255/255, alpha: 1).cgColor
        }else{
            self.agreeBtn.layer.backgroundColor = UIColor.gray.cgColor
        }
        self.checkBtn.setImage(UIImage(named: "noCheck"), for: .normal)
        self.checkBtn.setImage(UIImage(named: "check"), for: .selected)
                            
    }
    @IBAction func check(_ sender: Any) {
        self.checkBtn.isSelected = !self.checkBtn.isSelected
        CheckBtnDidTap()
    }
            
    @IBAction func agree(_ sender: Any) {
        
        if(self.checkBtn.isSelected){
            let enterVC = storyboard?.instantiateViewController(identifier: "enter") as! EnterViewController
            self.navigationController?.pushViewController(enterVC, animated: true)
        }else{
            print("同意してください")
        }
        
    }
    

}
