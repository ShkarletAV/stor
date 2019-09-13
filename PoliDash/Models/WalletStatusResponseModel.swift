//
//  WalletStatusResponseModel.swift
//  PoliDash
//
//  Created by XXXX on 18/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import ObjectMapper

class WalletStatusResponseModel: Mappable {
    enum StatusStates {
        case Declined
        case Accepted
    }
    
    var msg: String?
    var code: Int?
    var status: String?
    var statusState: StatusStates? {
        get {
            var temp:StatusStates?
            if status == "accepted" {
                temp = .Accepted
            } else if status == "declined" {
                temp = .Declined
            }
            
            return temp
        }
    }
    
    var address: String?
    var orderId: Int = 0
    //    var error : String?
    init() {

    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
        status <- map["status"]
        address <- map["address"]
        orderId <- map["id"]
    }

}
