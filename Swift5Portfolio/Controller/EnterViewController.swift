//
//  EnterViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/18.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Lottie

class EnterViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startBtn: UIButton!
    
    var animationArray = ["swipeToLeft","hello","video","news","bookMark",""]
    var animationTextArray = ["左にスワイプしてね!!","こんにちは!!\nこのアプリの紹介をするよ!","YouTubeの動画が見れるよ","最新のニュースが読めるよ","全メンバーのブログが見れるよ",""]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.isPagingEnabled = false
        
        setUpScroll()
        playAnimation()
        print(UIScreen.main.bounds.size.width)
    }
        
        
    func setUpScroll(){
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 6, height: UIScreen.main.bounds.height)
        
        
        for i in 0...5{
            //文字の高さ
            let animationTextLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: UIScreen.main.bounds.height / 20 * 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 3 / 5))
            
            if i == 5{
                var startBtn = UIButton()
                if UIScreen.main.bounds.size.width < 380{
                    startBtn = UIButton(frame: CGRect(x: Int(UIScreen.main.bounds.width)*50/10, y:Int(UIScreen.main.bounds.height)*51/100 , width: Int(UIScreen.main.bounds.width)/5*4, height: Int(UIScreen.main.bounds.height)/11))
                    print("12")
                }else{
                    startBtn = UIButton(frame: CGRect(x: Int(UIScreen.main.bounds.width)*51/10, y:Int(UIScreen.main.bounds.height)*51/100 , width: Int(UIScreen.main.bounds.width)/5*4, height: Int(UIScreen.main.bounds.height)/14))
                    print("12234")
                }
                
                       
                startBtn.backgroundColor = .black
                startBtn.setTitle("早速始めよう", for: .normal)
                startBtn.setTitleColor(.white, for: .normal)
                startBtn.layer.backgroundColor = UIColor(red: 163/255, green: 32/255, blue: 255/255, alpha: 1).cgColor
                startBtn.addTarget(self, action: #selector(tapBtn(_:)), for: UIControl.Event.touchUpInside)
                scrollView.addSubview(startBtn)
            }
            
            animationTextLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            animationTextLabel.textAlignment = .center
            animationTextLabel.text = animationTextArray[i]
            animationTextLabel.numberOfLines = 2
            scrollView.addSubview(animationTextLabel)
            
        }
        
    }

    func playAnimation(){
        for i in 0...4{
            let animationView = AnimationView()
            let animation = Animation.named(animationArray[i])
            animationView.animation = animation
            animationView.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.width, y: UIScreen.main.bounds.height / 50 * 10, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height / 3)
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            
            animationView.play()
            
            scrollView.addSubview(animationView)
        }
    }
    
    
    @objc func tapBtn(_ : UIButton){
        performSegue(withIdentifier: "select", sender: nil)
    
        print("1")
    }
}
