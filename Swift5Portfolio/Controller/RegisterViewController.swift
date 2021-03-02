//
//  ResisterViewController.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/01.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    var userInfo:[UserInfo] = []
    var userInfo2:[UserInfo2] = []
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    @IBAction func tapImage(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func register(_ sender: Any) {
        checkEmail()
//        setUser()
        
    }
    
    //入力されたemailが存在するかのcheckをする。
    func checkEmail(){
        Firestore.firestore().collection("メールアドレスとユーザーネームの紐付け").addSnapshotListener() { (snapShot, error) in
        self.userInfo = []
        
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    
                    if let email = data["email"],let userName = data["userName"]{
                        
                        let newInfo = UserInfo(email: email as! String, userName: userName as! String)
                        
                        self.userInfo.append(newInfo)
                        
                    }
                }
            }
            
            for i in 0...self.userInfo.count-1{
                if self.userInfo[i].email == self.emailTextField.text!{
                    self.alert(string: "このemailアドレスは使われています。")
                    return
                }
            }
            
            for i in 0...self.userInfo.count-1{
                if self.userInfo[i].userName == self.userNameTextField.text!{
                    self.alert(string: "このuserNameは使われています。")
                    return
                }
            }
            
            self.setUser()
        }
    }
        
    func alert(string:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: "エラー", message: string, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: "もう一度入力する", style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }
    
    
    
    func setUser(){
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            Firestore.firestore().collection("メールアドレスとユーザーネームの紐付け").addDocument(data: ["userName":self.userNameTextField.text,"email":self.emailTextField.text]) { (error) in

                if error != nil{
                    print(error.debugDescription)
                    print(error)
                    return
                }
                
                //テスト用に作成
                Firestore.firestore().collection("users").document(String(Auth.auth().currentUser!.uid)).setData(["createdAt": Date().timeIntervalSince1970,"email":Auth.auth().currentUser?.email,"userId": String(Auth.auth().currentUser!.uid)]) { (error) in
                    if error != nil{
                        print(error.debugDescription)
                        print(error)
                        return
                    }

                    print("アカウントの作成に成功しました!!")
                    
                    UserDefaults.standard.set(self.userNameTextField.text, forKey: "userName")
                    UserDefaults.standard.set(self.emailTextField.text, forKey: "email")
                    //画像を圧縮
                    let profileImageData = self.profileImageView.image?.jpegData(compressionQuality: 0.1)
                    
                    self.storeImage(data: profileImageData!)

                    let homeVC = self.storyboard?.instantiateViewController(identifier: "home")
                    homeVC?.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(homeVC!, animated: true)
                    
                }
            }
        }
    }
    
    
    //strageにprofileImageを保存する関数
    func storeImage(data:Data){
        let image = UIImage(data: data)
        let profileImageData = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("profileImage").child("\(emailTextField.text!).jpeg")
        
        
        //strageに画像保存
        imageRef.putData(profileImageData!, metadata: nil) { (metaData, error) in
            if error != nil{
                print(error.debugDescription)
                return
            }
 
            //いつでもDLできるようにリンク取得
            //今回は得たリンクをuserdefaultに保存してchatとかで表示させている。
            imageRef.downloadURL { (url, error) in
                if error != nil{
                
                    print(error.debugDescription)
                    return
                }
                
                
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "userImage")
                print(UserDefaults.standard.object(forKey: "userImage"))
            }
        }
    }
    
    //端末のカメラを開く関数
    func openCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        
        //カメラ利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
        
    }
    
    //アルバムを開く関数
    func openAlbum(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        //アルバムが 利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //albumから写真を選択した場合の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            
            let selectedImage = info[.originalImage] as! UIImage
            profileImageView.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
            
    func showActionSheet(){
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか?", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.openCamera()
        }
        let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.openAlbum()
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }
    

}
