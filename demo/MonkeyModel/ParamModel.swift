//
//  ParamModel.swift
//  demo
//
//  Created by holla on 2018/10/23.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

class ParamModel: MKModel {
    
    var param1: String!
    var param2: String!

//    var 
    override func mapping(map: Map) {
        param1 <- map["param1"]
        param2 <- map["param2"]
    }
    
    
}
