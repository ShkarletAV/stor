//
//  Owners_Model.swift
//  PoliDash
//
//  Created by David Minasyan on 31.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class CircleResponse: Mappable{
    var circles : [Owners_Model]?
    var code : Int?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        circles <- map["circles"]
        code <- map["code"]
    }
}

class Owners_Model: Mappable{
    var email : String?
    var id : Int?
    var last_login : String?
    var nickname : String?
    var notify : Notify?
    var picture : String?
    var video : [HistoryVideo]?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        id <- map["id"]
        last_login <- map["last_login"]
        nickname <- map["nickname"]
        notify <- map["notify"]
        picture <- map["picture"]
        video <- map["video"]
    }
    
}

class Notify: Mappable{
    var follower : Bool?
    var video: Bool?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        follower <- map["follower"]
        video <- map["video"]
    }
}
