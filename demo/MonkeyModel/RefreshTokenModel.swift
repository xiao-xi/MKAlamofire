//
//  RefreshTokenModel.swift
//  demo
//
//  Created by holla on 2018/10/29.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

class RefreshTokenModel: MKModel {

    override static func primaryKey() -> String? {
        return "token_type"
    }
    
    @objc dynamic var access_token: String?
    
    @objc dynamic var token_type: String?
    
    var expires_in: Int64?
    
    @objc dynamic var refresh_token: String?
    
    override func mapping(map: Map) {
        access_token <- map["access_token"]
        token_type <- map["token_type"]
        expires_in <- map["expires_in"]
        refresh_token <- map["refresh_token"]
    }
}
