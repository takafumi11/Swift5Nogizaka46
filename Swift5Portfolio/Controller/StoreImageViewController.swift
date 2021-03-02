//
//  StoreImageViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2021/01/14.
//  Copyright © 2021 野入隆史. All rights reserved.
//

import UIKit
import SDWebImage

protocol CatchUrlProtocol {
    func catchUrlString(urlString:String)
}

class StoreImageViewController: UIViewController {

    var top:String = ""
    var bottom:String = ""
    
    var delegate:CatchUrlProtocol?
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate?.catchUrlString(urlString: UserDefaults.standard.object(forKey: "MEA") as! String)
        
        topImageView.sd_setImage(with: URL(string: top), completed: nil)
        bottomImageView.sd_setImage(with: URL(string: bottom), completed: nil)

        topImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.saveImage(_:))))
        bottomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.saveImage(_:))))
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func saveImage(_ sender:UITapGestureRecognizer){
        //タップしたUIImageViewを取得
        let targetImageView = sender.view! as! UIImageView
        // その中の UIImage を取得
        let targetImage = targetImageView.image!
        //保存するか否かのアラート
        let alertController = UIAlertController(title: "保存", message: "この画像をアルバムに保存しますか？", preferredStyle: .alert)
        //OK
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            //ここでフォトライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(targetImage, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        //CANCEL
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        //OKとCANCELを表示追加し、アラートを表示
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //保存結果をアラートで表示
    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {

        var title = "完了"
        var message = "カメラロールに保存しました!"

        if error != nil {
            title = "エラー"
            message = "保存に失敗しました、、、"
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
    }
    
}
