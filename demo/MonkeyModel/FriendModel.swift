
//
//  Friend.swift
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

class friendModel: MKModel {
    var friend_id: String!
    //
    override func mapping(map: Map) {
        friend_id <- map["id"]
    }
}
