//
//  Message.swift
//  Swift5Portfolio
//
//  Created by 野入隆史 on 2020/11/01.
//  Copyright © 2020 野入隆史. All rights reserved.
//

import Foundation


struct RoomModel {
    var roomName:String
    var roomImage:[String]
    var updateDate:String
    var author:String
}

struct MessageModel {
    let sender:String
    let body:String
    let imageString:String
    let email:String
    //表示用
    let date:String
    
}


