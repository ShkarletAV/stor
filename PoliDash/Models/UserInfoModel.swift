//
//  UserInfo.swift
//  PoliDash
//
//  Created by David Minasyan on 20.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class Balance: Mappable {
    var balance = 0
    var code: Int?

    init() {

    }

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        code <- map["code"]
        balance <- map["balance"]
    }
}

class UserInfoModel: Mappable {
    var code: Int?
    var email: String?
    var nickname: String?
    var id: Int?
    var picture: String?
    var msg: String?
    var notify: Notify?

    init() {

    }

    required init?(map: Map) {
        mapping(map: map)
    }

    func mapping(map: Map) {
        code <- map["code"]
        email <- map["email"]
        nickname <- map["nickname"]
        id <- map["id"]
        picture <- map["picture"]
        notify <- map["notify"]
    }
}
