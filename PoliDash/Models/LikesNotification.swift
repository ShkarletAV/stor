//
//  LikesNotification.swift
//  PoliDash
//
//  Created by Ігор on 3/25/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import ObjectMapper

class FollowersNotificationMessage: Mappable{
    var msg: [Owners_Model]?
    var code : Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }
    
    init(){
        
    }
    
}


class LikesNotificationMessage: Mappable{
    var msg: [HistoryVideo]?
    var code : Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }
    
    init(){
        
    }
    
}


class LikesNotification: Mappable{
    var email : String?
    var followers_amount : Int?
    var nickname : String?
    var notification_hash : String?
    var picture : String?
    var sympathy : LikeSympathy?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        followers_amount <- map["followers_amount"]
        nickname <- map["nickname"]
        picture <- map["picture"]
        notification_hash <- map["notification_hash"]
        sympathy <- map["sympathy"]
    }
    
    init(){
        
    }
    
}

class LikeSympathy: Mappable{
    var cx : String?
    var cy : String?
    var picture : String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        cx <- map["cx"]
        cy <- map["cy"]
        picture <- map["picture"]
    }
    
    init(){
        
    }
    
}
