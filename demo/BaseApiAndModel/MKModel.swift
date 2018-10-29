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
    
    //将json数据转化为模型
    static private func getJSONModel<T: MKModel>(_ json: [String: Any], _ modelType:T.Type) -> T?{
        guard let jsonModel = Mapper<T>().map(JSON: json) else {
            return nil
        }
        return jsonModel
    }
    
    //将json数据转化模型数组
    static private func getJSONArrayModel<T: MKModel>(_ jsonArray: [[String : Any]], _ modelType:T.Type) -> [T]?{
        let jsonArrayModel = Mapper<T>().mapArray(JSONArray: jsonArray)
        
        if jsonArrayModel.count == 0 {
            return nil
        }
        return jsonArrayModel
    }
}

