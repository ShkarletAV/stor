//
//  messageModel.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageModel: Mappable{
    var msg: String?
    var code : Int?
//    var error : String?
    init(){
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }
    
}


class NotificationModel: Mappable{
    var msg: Bool?
    var code : Int?
    var followers : Int?
    var likes : Int?
    //    var error : String?
    init(){
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
        followers <- map["followers"]
        likes <- map["likes"]
    }
    
}
