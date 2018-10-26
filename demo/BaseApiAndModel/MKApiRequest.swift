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
import Alamofire

enum DataType {
    case JSON
    case JSONArray
    case Default
}

class MKApiRequest: MKBaseRequest {
    typealias successCompletionHandler<T: MKModel> = (_:T? ,_:[T]?) -> Void
    
    typealias failedModelCompletionHandler = (_:MKErrorModel) -> Void
    
    typealias successJSONCompletionHandler<T: MKModel> = (_:MKBaseRequest, _:T?) -> Void
    typealias successArrayCompletionHandler<T: MKModel> = (_:MKBaseRequest, _:[T]?) -> Void
    typealias failedCompletionHandler = (_:MKBaseRequest, _:MKErrorModel?) -> Void
    
    // 设置接口是否需要realm存储数据，默认为false
    var needRealm: Bool {
        return false
    }
    
    var netParams: [String: Any]?
    
    var dataKey: String{
        return "data"
    }
    
    override var requestParams: [String : Any]?{
        return self.netParams
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
    
    public func startWithJSONResponse<T: MKModel>(_ responseType:T.Type, success successHandler:@escaping successJSONCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void{
        self.startWithCompletion(.JSON, success: { (jsonModel, jsonArray) in
            successHandler(self, jsonModel)
        }) { (errModel) in
            failedHandler(self, errModel)
        }
    }
    
    public func startWithJSONArrayResponse<T: MKModel>(_ responseType:T.Type, success successHandler:@escaping successArrayCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void{
        self.startWithCompletion(.JSONArray, success: { (jsonModel, jsonArray) in
            successHandler(self, jsonArray)
        }) { (errModel) in
            failedHandler(self, errModel)
        }
    }
    
    public func startWithCompletion<T: MKModel>(_ responseType: DataType,success successHandler:@escaping successCompletionHandler<T>, failed failedHandler: @escaping failedModelCompletionHandler) -> Void{
        self.start({ (request) in
            
            var jsonData : Any?
            var errModel : MKErrorModel?
            switch request.statusCode{
            case 200:
                //网络请求成功了,根据data路径找到需要的数据
                jsonData = self.getJSONData(request)
                break
            default:
                //网络请求失败了
                errModel = self.getErrInfo(request)
                failedHandler(errModel!)
                break
            }
            
            if errModel != nil{
                return
            }
            //根据responseType进行处理数据
            switch responseType{
            case .JSON:
                let jsonModel = self.getJSONModel(jsonData as! [String: Any], T.self)
                successHandler(jsonModel, nil)
                break
            case .JSONArray:
                let jsonArrayModel = self.getJSONArrayModel(jsonData as! [[String: Any]], T.self)
                successHandler(nil, jsonArrayModel)
                break
            case .Default:
                
                break
            }
            
        }) { (request) in
            //将request.error中的信息处理到ErrorModel中
//            request.error
            let errModel = MKErrorModel()
            errModel.error = request.error
            failedHandler(errModel)
        }
    }
    
    //通过self.dataKey ，request.responseJson 获取json数据并返回
    private func getJSONData(_ request: MKBaseRequest) -> [String: Any]?{
        
//        return request.responseJson![self.dataKey] as? [String : Any]
        return request.responseJson
    }
    
    //通过request.responseJson获取网络请求失败后服务器返回错误信息
    private func getErrInfo(_ request: MKBaseRequest) -> MKErrorModel?{
        let errModel = Mapper<MKErrorModel>().map(JSON: request.responseJson!)
        errModel?.error = request.error
        return errModel
    }
    
    //将json数据转化为模型
    private func getJSONModel<T: Mappable>(_ json: [String: Any], _ modelType:T.Type) -> T?{
        let jsonModel = Mapper<T>().map(JSON: json)
        return jsonModel
    }
    
    //将json数据转化模型数组
    private func getJSONArrayModel<T: Mappable>(_ jsonArray: [[String : Any]], _ modelType:T.Type) -> [T]?{
        let jsonArrayModel = Mapper<T>().mapArray(JSONArray: jsonArray)
        return jsonArrayModel
    }
    
    //将模型写入数据库，并把从数据库读出的此模型返回
    private func writeJSONToRealm<T: Mappable>(_ jsonModel: T) -> T{
        //这里进行存取
        return jsonModel
    }
    //将模型数组写入数据库，并把从数据库读出的此模型数组返回
    private func writeJSONArrayToRealm<T: Mappable>(_ jsonArrModel: [T]) -> [T]?{
        //这里进行存取
        return jsonArrModel
    }
}
