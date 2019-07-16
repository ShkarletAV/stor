//
//  HistoryVideoModel.swift
//  PoliDash
//
//  Created by David Minasyan on 26.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class AllHistoryesVideo{
    var allHistoryes = [HistorysVideoModel]()
}

class HistorysVideoModel: Mappable{
  
    var statusCode : Int?
    var error : String?
    
    var historys: [HistoryVideo]?
    var saved: [SavedVideo]?
    init(){
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        historys <- map["history"]
        saved <- map["saved"]
    }
}

class HistoryVideo: Mappable {
    var hash : String?
    var preview : String?
    var video : String?
    var duration: Int?
    var date : String?
    init(){
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        duration <- map["duration"]
        hash <- map["hash"]
        preview <- map["preview"]
        video <- map["video"]
        date <- map["date"]
    }
}

class SavedVideo: Mappable{
    var id : Int?
    var videos : [HistoryVideo]?
  
    init(){
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        videos <- map["videos"]
    }
    
    
}
