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

typealias completeFailedHandler = (_: MKBaseRequest, _:MKErrorModel?) -> Void

class MKApiRequest: MKBaseRequest {
    
    // 设置接口是否需要realm存储数据，默认为false
    var needRealm: Bool {
        return false
    }
    
    //默认设置请求方式为get
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.get
    }
    
    //默认设置encoding格式为url
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.url
    }
    
    //设置httpheaders
    override var requestHeaders: MKHTTPHeaders?{
        let client = Environment.bundleId
        let version = Environment.appVersion
        var headerDic = [
            "Device":"iOS",
            "Accept":"application/vnd.api+json, application/json",
            "Content-Type":"application/vnd.api+json",
            "Version":version,
            "Client":client
        ]
        //判断是否有Authorization
        if Environment.authorization != nil {
            headerDic["authorization"] = "Authorization value"
            return headerDic
        }
        return headerDic
    }
    
    /* get response JsonData,
        - Parameters:
        - responseClass: Class.self
        - finishSuccessHandler: block success
        - finishFailedHandler: block failed
     */
    func getJsonDataWithCompletionHandler<T: Mappable>(_ responseClass:T.Type,success finishSuccessHandler:@escaping completeJSONHandler<T>, failed finishFailedHandler:@escaping completeFailedHandler) -> Void{
        //start request with proprety of self
        self.start({ (successRequest) in
            
            guard (successRequest.responseJson != nil) else{
                return
            }
    
            if let data = successRequest.responseJson {
                let resJson = Mapper<T>().map(JSON: data["data"] as! [String : Any])
                if self.needRealm{
                    self.writeRealm(resJson)
                }
                
                finishSuccessHandler(self, resJson)
            }
        }) { (failedRequest) in
            if let data = failedRequest.responseJson {
                let errModel = Mapper<MKErrorModel>().map(JSON: data)
                finishFailedHandler(self, errModel)
            }else{
                finishFailedHandler(self, nil)
            }
        }
    }
    
    /* get response JsonArray,
     - Parameters:
     - responseClass: Class.self
     - finishHandler: block success
     - finishFailedHandler: block failed
     */
    func getJsonArrayDataWithCompletionHandler<T: Mappable>(_ responseClass:T.Type,success finishSuccessHandler:@escaping completeJSONArrayHandler<T>, failed finishFailedHandler:@escaping completeFailedHandler) -> Void{
        self.start({ (baseRequest) in
            //这里返回的数据应该取出data字段中的数据转化为jsonString
            //再使用Mapper<T>().mapArray(JSONfile: jsonString)方法转化为数组
            //最后进行回调
            let resJsonArray = Mapper<T>().mapArray(JSONString: "")
            finishSuccessHandler(self, resJsonArray)
        }) { (baseRequest) in
            finishFailedHandler(self, nil)
        }
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
