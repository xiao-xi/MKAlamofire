//
//  BaseApiRequest.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

typealias completeJSONHandler<O: Mappable> = (_: MKBaseRequest, _:O?) -> Void

typealias completeJSONArrayHandler<O: Mappable> = (_: MKBaseRequest, _:[O]?) -> Void

class BaseApiRequest: MKBaseRequest {
    
    // 设置接口是否需要存储数据
    var needRealm: Bool {
        return false
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.get
    }
    
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.url
    }
    
    //设置httpheader,
    override var requestHeaders: MKHTTPHeaders?{
        //判断是否有Authorization
        return [
            "lang": "en-CN",
            "Version":"5.0",
            "Client":"cool.monkey.ios",
            "Device":"iOS",
            "Accept":"application/vnd.api+json, application/json",
            "Content-Type":"application/vnd.api+json",
            "User-Agent":"Sandbox/5.0 (cool.monkey.ios; build:73; iOS 11.4.1) Alamofire/4.7.3"
        ]
    }
    /* get response JsonData,
        - Parameters:
        - responseClass: Class.self
        - finishHandler: block response
     */
    func getJsonDataWithCompletionHandler<T: Mappable>(_ responseClass:T.Type,_ finishHandler:@escaping completeJSONHandler<T>) -> Void{
        //start request with proprety of self
        self.start({ (successRequest) in
            guard (successRequest.responseJson != nil) else{
                return
            }
            
            //
            if let err = successRequest.error{
                print("err info is \(err.localizedDescription)")
                finishHandler(self, nil)
                return
            }
            
            if let data = successRequest.responseJson {
                let resJson = Mapper<T>().map(JSON: data["data"] as! [String : Any])
                if self.needRealm{
                    self.writeRealm(resJson)
                }
                
                finishHandler(self, resJson)
            }
            
            print("request success")
            
        }) { (failedRequest) in
            finishHandler(self, nil)
            print("request failed")
        }
    }
    
    /* get response JsonArray,
     - Parameters:
     - responseClass: Class.self
     - finishHandler: block response
     */
    func getJsonArrayDataWithCompletionHandler<T: Mappable>(_ responseClass:T.Type,_ finishHandler:@escaping completeJSONArrayHandler<T>) -> Void{
        self.start({ (baseRequest) in
        
        }) { (baseRequest) in
        
        }
        
        let resJsonArray = Mapper<T>().mapArray(JSONfile: "")
        finishHandler(self, resJsonArray)
    }
    
    /// 写入realm数据库(write to realm db)
    ///
    /// - Parameter model: 需要写入的数据模型(the model of data)
    /// - Returns: 写入结果(result)
    private func writeRealm<T:Mappable>(_ model:T?) -> Void {
        // Get the default Realm
        let realm = try! Realm()
        // Persist your data easily
        try! realm.write {
//            realm.add(model as! Object)
        }
    }
}
