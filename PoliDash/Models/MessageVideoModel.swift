//
//  MessageVideoModel.swift
//  PoliDash
//
//  Created by David Minasyan on 26.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageVideoModel: Mappable {
    var code: Int?
    var msg: String?
    var preview: String?
    var video: String?

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        code <- map["code"]
        msg <- map["msg"]
        preview <- map["preview"]
        video <- map["video"]
    }
}

class MessageVideoProgress: Mappable {
    var progress: Progress?
    var msg: String?

    init() {
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        progress <- map["progress"]
        msg <- map["msg"]
    }
}
