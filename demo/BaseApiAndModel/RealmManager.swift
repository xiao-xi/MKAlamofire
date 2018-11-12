//
//  RealmManager.swift
//  demo
//
//  Created by holla on 2018/10/29.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager: NSObject {
    
    /// 把jsonArrayModel 写入数据库，并返回写入后数据库中的数据模型
    ///
    /// - Parameter jsonArrModel: 将要写入的数据模型
    /// - Returns: 数据库中的数据模型
    static func writeJSONArrayToRealm<T: MKModel>(_ jsonArrModel: [T]) -> [T]?{
        guard jsonArrModel.count > 0 else {
            return nil
        }
        var realmObjects:[T]?
        jsonArrModel.forEach { (jsonModel) in
            guard let realmobject = self.writeJSONToRealm(jsonModel) else{
                return
            }
            realmObjects?.append(realmobject)
        }
        return realmObjects
    }
    
    
    /// 把模型对象写入realm数据库
    ///
    /// - Parameter jsonModel: 模型对象
    /// - Returns: 从realm数据库取出模型对象
    static func writeJSONToRealm<T: MKModel>(_ jsonModel: T) -> T?{
        //打开数据库
        let realm = try! Realm()
        print(realm.configuration.fileURL!)
        guard let primaryKey = T.primaryKey() else {
            //没有主键
            MKLog("no primaryKey, All subclasses of MKModel must have a primary key!")
            return nil
        }
        //查询数据库是否存在jsonModel
        guard let realmObject = realm.object(ofType: T.self, forPrimaryKey: jsonModel.value(forKey: primaryKey)) else {
            try! realm.write {
                realm.add(jsonModel) // 增加单个数据
            }
            //return realmObject
            return realm.object(ofType: T.self, forPrimaryKey: jsonModel.value(forKey: primaryKey))
        }
        
        //如果存在，从数据库中取出这个对象，将jsonModel的各项值赋值给它，再将它写入数据库
        //不使用update方法的原因是存储的对象有可能包含responseJson不具备的属性，update方法会导致这些属性被删除
        guard let properties = T.sharedSchema()?.properties else{
            return nil
        }
        
        try! realm.write {
            properties.forEach({ (property) in
                //主键是不是property，必须过滤主键，主键不可以更改
                if property.name == primaryKey{
                    return
                }
                let newValue = jsonModel.value(forKey: property.name)
                realmObject.setValue(newValue, forKey: property.name)
            })
        }
        return realm.object(ofType: T.self, forPrimaryKey: jsonModel.value(forKey: primaryKey))
    }
}
