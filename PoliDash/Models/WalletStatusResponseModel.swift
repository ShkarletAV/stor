//
//  WalletStatusResponseModel.swift
//  PoliDash
//
//  Created by olya on 18/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import ObjectMapper

class WalletStatusResponseModel: Mappable {
    var msg: String?
    var code: Int?
    var status: Int?
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
