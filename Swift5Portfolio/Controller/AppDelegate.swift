//
//  AppDelegate.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/10/18.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FirebaseMessaging
import UserNotifications
import GoogleMobileAds
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let hour = 15
    let minute = 04
    //push通知のフラグ？？
    var notificationGranted = true
    
    var isFirst = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //googleMobileAdsを初期化（使えるように）する
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //アプリ内課金を使えるようにする
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
             for purchase in purchases {
                 switch purchase.transaction.transactionState {
                 case .purchased, .restored:
                     if purchase.needsFinishTransaction {
                         SwiftyStoreKit.finishTransaction(purchase.transaction)
                     }
                 // Unlock content
                 case .failed, .purchasing, .deferred:
                     break // do nothing
                 @unknown default:
                    fatalError()
                }
             }
        }
            
        //通知の許可
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        isFirst = false
        setNotification()
        
        //textを入力する時キーボードを上に押し上げる
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        return true
    }
    
    //(ローカル通知)
    func setNotification(){
        var notificationTime = DateComponents()
        var trigger:UNNotificationTrigger
        
        notificationTime.hour = hour
        notificationTime.minute = minute
        trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "おはようございます!"
        content.body = "更新情報を確認してみましょう!!!"
        content.sound = .default
        
        //通知スタイル
        let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
        
        //通知セット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //タスクキル後も通知がくるようにする
    //appdelegateのメソッド
    func applicationDidEnterBackground(_ application: UIApplication) {
        setNotification()
    }
    
    //プッシュ通知(リモート通知)の受信処理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       // Print message ID.
       if let messageID = userInfo["gcm.message_id"] {
           print("Message ID: \(messageID)")
       }

       // Print full message.
       print(userInfo)
    }
    
    //バックグラウンドにいる時の受信処理
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       // Print message ID.
       if let messageID = userInfo["gcm.message_id"] {
           print("Message ID: \(messageID)")
       }

       // Print full message.
       print(userInfo)

       completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //アプリがフォアグラウンドに来たときに呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       let userInfo = notification.request.content.userInfo

       if let messageID = userInfo["gcm.message_id"] {
           print("Message ID: \(messageID)")
       }

       print(userInfo)

       completionHandler([ .badge, .sound, .banner ])
    }

    //バックグラウンドの際に来た通知をタップ後、アプリが起動したら呼ばれる
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
       let userInfo = response.notification.request.content.userInfo
       if let messageID = userInfo["gcm.message_id"] {
           print("Message ID: \(messageID)")
       }

       print(userInfo)

       completionHandler()
   }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

