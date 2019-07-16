//
//  LikesNotification.swift
//  PoliDash
//
//  Created by Ігор on 3/25/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit
import ObjectMapper

class FollowersNotificationMessage: Mappable {
    var msg: [OwnersModel]?
    var code: Int?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }

    init() {

    }

}

class LikesNotificationMessage: Mappable {
    var msg: [HistoryVideo]?
    var code: Int?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        msg <- map["msg"]
        code <- map["code"]
    }

    init() {

    }

}

class LikesNotification: Mappable {
    var email: String?
    var followersAmount: Int?
    var nickname: String?
    var notificationHash: String?
    var picture: String?
    var sympathy: LikeSympathy?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        email <- map["email"]
        followersAmount <- map["followers_amount"]
        nickname <- map["nickname"]
        picture <- map["picture"]
        notificationHash <- map["notification_hash"]
        sympathy <- map["sympathy"]
    }

    init() {

    }

}

class LikeSympathy: Mappable {
    var cx: String?
    var cy: String?
    var picture: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        cx <- map["cx"]
        cy <- map["cy"]
        picture <- map["picture"]
    }

    init() {

    }

}
