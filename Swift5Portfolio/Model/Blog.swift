//
//  Blog.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/12/05.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import Foundation

struct BlogModel {
    var title:String
    var body:String
    var imageString:[String]
    var url:String
    var date:String
    var author:String
    let userNmae:String
    let docID:String
    let likeCount:Int
    let likeFlagDic:Dictionary<String,Any>
    var face:String
    var postDate:NSNumber
}


//chatに送る用の構造体
struct LikeModel {
    var title:String
    var body:String
    var imageString:[String]
    var url:String
    var date:String
    var author:String
    let userNmae:String
    let docID:String
    let likeCount:Int
    let likeFlagDic:Dictionary<String,Any>
    var face:String
    var postDate:NSNumber
}
