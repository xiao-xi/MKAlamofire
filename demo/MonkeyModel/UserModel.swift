//
//  UserModel.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

class UserModel: MKModel {
    var relationships: [String: Any]?
    
    var action: String!
    
    var attributes: [String: Any]?
    
    var user_id: String!
    
    override func mapping(map: Map) {
        user_id <- map["id"]
        action <- map["action"]
        attributes <- map["attributes"]
    }
    
}
