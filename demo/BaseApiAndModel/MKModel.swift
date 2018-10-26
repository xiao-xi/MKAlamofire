//
//  BaseModel.swift
//  demo
//
//  Created by holla on 2018/10/23.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import ObjectMapper

class MKModel: Mappable {
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    required init() {
        
    }
    
    func mapping(map: Map) {
        
    }
}


