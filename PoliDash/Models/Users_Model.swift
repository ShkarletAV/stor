//
//  Users_Model.swift
//  PoliDash
//
//  Created by David Minasyan on 28.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class UsersModel: Mappable{
    var email : String?
    var id : Int?
    var last_login : String?
    var nickname : String?
    var picture : String?
    var video : [HistoryVideo]?
    var notify : Notify?
//    var hist = HistoryVideo()
//    var rowItem = 0
  
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        id <- map["id"]
        last_login <- map["last_login"]
        nickname <- map["nickname"]
        picture <- map["picture"]
        video <- map["video"]
        notify <- map["notify"]
    }
    
    init(){
        
    }
    
}
