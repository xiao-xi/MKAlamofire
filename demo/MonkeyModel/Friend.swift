//
//  Friend.swift
//  demo
//
//  Created by holla on 2018/10/30.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

class FriendModel: MKModel {
    
    override static func primaryKey() -> String? {
        return "friend_id"
    }
    
    dynamic var friend_id: Int64 = 0
    
    dynamic var friendship_id: String?
    
    dynamic var created_at: Int64 = 0
    
    override func mapping(map: Map) {
        friend_id <- map["friend_id"]
        friendship_id <- map["friendship_id"]
        created_at <- map["created_at"]
    } 
}
