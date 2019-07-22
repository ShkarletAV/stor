//
//  VideoCyrcleModel.swift
//  PoliDash
//
//  Created by olya on 21/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import ObjectMapper

class VideoCircleModel: Mappable {
    
    var circle: [VideoCircleItem]?

    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        circle <- map["circle"]
    }
}

class VideoCircleItem: Mappable {
    var msg: String?
    var code: Int?
    //    var error : String?
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }
    
}
