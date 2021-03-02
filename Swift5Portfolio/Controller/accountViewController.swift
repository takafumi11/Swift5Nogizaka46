//
//  accountViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/19.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit

class accountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func register(_ sender: Any) {
        let registerVC = storyboard?.instantiateViewController(identifier: "register")        
        self.navigationController?.pushViewController(registerVC!, animated: true)
    }
    @IBAction func login(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(identifier: "login")
        self.navigationController?.pushViewController(loginVC!, animated: true)
        
    }
    
}
