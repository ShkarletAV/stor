//
//  Owners_Model.swift
//  PoliDash
//
//  Created by David Minasyan on 31.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class CircleResponse: Mappable {
    var circles: [OwnersModel]?
    var code: Int?

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        circles <- map["circles"]
        code <- map["code"]
    }
}

class OwnersModel: Mappable {
    var email: String?
    var id: Int?
    var lastLogin: String?
    var nickname: String?
    var notify: Notify?
    var picture: String?
    var video: [HistoryVideo]?

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        email <- map["email"]
        id <- map["id"]
        lastLogin <- map["last_login"]
        nickname <- map["nickname"]
        notify <- map["notify"]
        picture <- map["picture"]
        video <- map["video"]
    }

}

class Notify: Mappable {
    var follower: Bool?
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
