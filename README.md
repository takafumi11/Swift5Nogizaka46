 # Swift5Nogizaka46

乃木坂46の最新情報を取得するアプリ。

## 環境
・MacbookPro ver.10.15.7  
・Swift5  
・Xcode ver.12.3  
実機テスト  
・iPhone8 iOS 14.3  
・iPhone11 Pro iOS 14.3  

## 機能一覧
###  1.アプリ紹介のアニメーション  
https://noifumi.com/NogizakaApp/intro.mp4
Lottieを使用してアプリを紹介する簡単なアニメーションを作成した。  
###  2.匿名・emailログイン  
FirebaseAuthを使用して匿名ログイン、email・Passwordログインを実装した。  
会員情報はFirestoreに保存しプロフィール画像はStorageに保存した。  
### 3.Youtube動画の視聴  
https://noifumi.com/NogizakaApp/youtube.mp4 
YouTubeDataAPI、Alamofire、SwiftyJSONを使用して動画を取得し、動画のサムネイル、タイトルを最新順に表示した。  
また、履歴を残しているので後から視聴も可能である。  
### 4.Yahoo!ニュース記事の閲覧。  
https://noifumi.com/NogizakaApp/news.mp4
Kanna、Alamofireを使用してYahoo!ニュースに対してHTMLParseを行った。  
### 5.全メンバーのブログを閲覧可能。(※公式サイトのurlがSSL化されていないのでhttp://~を弾く設定だと見れません。) 
https://noifumi.com/NogizakaApp/blog.mp4
4と同様の手段で公式サイトからブログ記事を取得した。  
公式サイトでは搭載されていない、お気に入り機能を追加した。  
また、文章の読みやすさを重視して余計な余白や画像を除外した。  
### 6.Line風なメモ、またはシェア可能。  
Line風なメモ機能を搭載した。
普段簡単なメモを取る際Lineで個人のグループを作成し、そこにメモをしているため使い慣れている手段を再現した。  
また、5においてお気に入りに登録したブログについてコメント、シェア可能。
### 7.Firebaseログアウト  
FirebaseAuthのログアウト機能を実装した。
### 8.GoogleAdMob　　
GoogleAdMobを使用してアプリ内広告(バナー)を実装した。
### 9.アプリ内課金  
8を配信停止する非消耗型のアプリ内課金を実装した。
### 10.通知
Firebaseを使用したリモート通知と、指定時刻に発火するローカル通知を実装した。
### 11.写真を端末に保存
機能5において写真を端末に保存可能。


## 工夫した点
1.機能一覧5において。
ブログ記事をparseし表示するまでは良かったが、お気に入り機能の実装に苦労した。
Firestoreでお気に入りに登録しているかしていないかを管理しているのだが、新しい記事が更新された時や表示するメンバーを変更した時にいくつかのエラーが発生した。
具体的にはFirestoreに保存するデータと、記事更新後に構造体に保存するデータの連携が取れなかった。
BlogViewControllerの該当する箇所にコメントで記載した。

2.現在のWebとネイティブアプリとの違いとしてDB設計が挙げられる。  
今回使用したFirestoreではWebのようにSQLを書く必要がなかった故に細かい動き、特に複数のDBの連携をすることができなかった。  
機能一覧6において上記の問題を解決するために構造体を組み合わせるなどの工夫をした。

## 使用技術一覧
### API
YouTubeDataAPI

### CocoaPods
1. Firebase
1. Firebase/Auth
1. Firebase/FireStore
1. Firebase/Storage
1. Lottie
1. Alamofire
1. Kanna
1. SwiftyJSON
1. SDWedImage
1. IQKeyboardManagerSwift
1. FirebaseMessaging
1. Google-Mobile-Ads-SDK
1. SwiftyStoreKit

