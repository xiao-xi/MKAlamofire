//
//  UserModel.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper
//import RealmSwift

class UserModel: MKModel {
    @objc dynamic var user_id: String?

    @objc dynamic var action: String?
    
    @objc dynamic var type: String?
    
    @objc dynamic var attributes: [String: Any]?
    
    @objc dynamic var relationships: [String: Any]?
    
    @objc dynamic var deep_link: [String: Any]?
    
    
    override static func primaryKey() -> String? {
        return "user_id"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["attributes", "relationships", "deep_link"]
    }
    
    override func mapping(map: Map) {
        user_id <- map["id"]
        action <- map["action"]
        type <- map["type"]
    }
    
}
