//
//  SympathyModel.swift
//  PoliDash
//
//  Created by David Minasyan on 04.08.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import ObjectMapper

class SympathyModel: Mappable {

    var code: Int?
    var count: Int?
    var likes: [Coordinates]?

    init() {}

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        code <- map["code"]
        count <- map["count"]
        likes <- map["likes"]
    }

}

class Coordinates: Mappable {

    var x: String?
    var y: String?

    init() {}

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        x <- map["x"]
        y <- map["y"]
    }
}
