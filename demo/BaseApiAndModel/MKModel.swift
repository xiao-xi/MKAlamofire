//
//  BaseModel.swift
//  demo
//
//  Created by holla on 2018/10/23.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Realm

//All properties must be primitives, NSString, NSDate, NSData, NSNumber, RLMArray, RLMLinkingObjects, or subclasses of RLMObject.
//See https://realm.io/docs/objc/latest/api/Classes/RLMObject.html for more information.'
class MKModel:Object, Mappable{
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
    }
    //重写此方法设置主键
//    override static func primaryKey() -> String? {
//        return ""
//    }
    
    //重写此方法可以忽略不合规则的属性
//    override class func ignoredProperties() -> [String] {
//        return []
//    }
}

