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
import Realm

//与后台约定返回数据的处理格式
//目前提供了json与jsonArray
//json返回调用`startWithJSONResponse`
//jsonArray返回调用`startWithJSONArrayResponse`
private enum DataType {
    case JSON
    case JSONArray
    case Default
}

class MKApiRequest: MKBaseRequest {
    
    //MARK: - alias block
    typealias successCompletionHandler<T: MKModel> = (_:T? ,_:[T]?) -> Void
    
    typealias failedModelCompletionHandler = (_:MKErrorModel?) -> Void
    
    typealias successJSONCompletionHandler<T: MKModel> = (_:MKBaseRequest, _:T?) -> Void
    typealias successArrayCompletionHandler<T: MKModel> = (_:MKBaseRequest, _:[T]?) -> Void
    typealias failedCompletionHandler = (_:MKBaseRequest, _:MKErrorModel?) -> Void
    
    //MARK: - custom params
    // 设置接口是否需要realm存储数据，默认为false
    var realm: Bool {
        return false
    }
    
    //网络请求参数，json类型 使用netParams的话不要重写`requestParams`方法
    var netParams: [String: Any]?
    
    //response数据存放的key，默认为data字段中的数据
    //有的返回数据不在此字段中，可以重写后返回nil
    //可传入形如"data.user.friends"的路径使用更深层级的数据
    //注意此路径里的内容必须为字典内容[String: Any]
    var dataKey: String?{
        return "data"
    }
    
    // requestHandler
    private var requestFailedHandler: failedModelCompletionHandler?
    
    //MARK: - override params
    //重写`requestParams`设置请求参数为`netParams`
    //使用中设置netParamsj即可
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
    
    //设置自定义的httpheaders
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
            headerDic["authorization"] = Environment.authorization
            return headerDic
        }
        
        return headerDic
    }
    
    
    //MARK: - Public Method

    /// 进行会返回模型对象的网络请求
    ///
    /// - Parameters:
    ///   - responseType: 期望的出参类型，用于接收返回数据
    ///   - successHandler: 请求成功的回调
    ///   - failedHandler: 请求失败e的回调
    public func startWithJSONResponse<T: MKModel>(_ responseType:T.Type, success successHandler:@escaping successJSONCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void{
        self.startWithCompletion(.JSON, success: { (jsonModel, jsonArray) in
            successHandler(self, jsonModel)
        }) { (errModel) in
            failedHandler(self, errModel)
        }
    }

    /// 进行会返回模型对象数组的网络请求
    ///
    /// - Parameters:
    ///   - responseType: 期望的出参类型，用于接收返回数据
    ///   - successHandler: 请求成功的回调
    ///   - failedHandler: 请求失败e的回调
    public func startWithJSONArrayResponse<T: MKModel>(_ responseType:T.Type, success successHandler:@escaping successArrayCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void{
        self.startWithCompletion(.JSONArray, success: { (jsonModel, jsonArray) in
            successHandler(self, jsonArray)
        }) { (errModel) in
            failedHandler(self, errModel)
        }
    }
    
    //MARK: - Private Method

    /// 根据参数类型返回数据模型或模型数组
    ///
    /// - Parameters:
    ///   - responseType: 期望的出参类型，用于接收返回数据
    ///   - successHandler: 请求成功的回调
    ///   - failedHandler: 请求失败e的回调
    private func startWithCompletion<T: MKModel>(_ responseType: DataType,success successHandler:@escaping successCompletionHandler<T>, failed failedHandler: @escaping failedModelCompletionHandler) -> Void{
        self.requestFailedHandler = failedHandler
        self.start({ (request) in
            DispatchQueue.global().async {
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
                    break
                }
                
                //jsondata转化失败
                if (jsonData == nil) {
                    self.requestFailed(MKErrorModel("no jsonData!"))
                    return
                }
                
                //网络失败
                if errModel != nil {
                    self.requestFailed(errModel)
                    return
                }
                
                //根据responseType进行处理数据
                switch responseType{
                case .JSON:
                    //判断jsonData的类型------
                    guard let json = jsonData as? [String : Any] ,let jsonModel = self.getJSONModel(json, T.self) else{
                        self.requestFailed(MKErrorModel("no jsonModel!"))
                        return
                    }
                    if self.realm{
                        let safeRef = ThreadSafeReference(to: jsonModel)
                        
                        DispatchQueue.main.async {
                            let realm = try? Realm()
                            let safeObject = realm?.resolve(safeRef)
                            successHandler(safeObject, nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            successHandler(jsonModel, nil)
                        }
                    }
                    
                    break
                case .JSONArray:
                    //判断jsonData的类型-----
                    guard let json = jsonData as? [[String : Any]] , let jsonArrayModel = self.getJSONArrayModel(json, T.self) else{
                        self.requestFailed(MKErrorModel("no jsonArrayModel!"))
                        return
                    }
                    
                    if self.realm {
                        let references = jsonArrayModel.map({
                            ThreadSafeReference(to: $0)
                        })
                        
                        DispatchQueue.main.async {
                            let realm = try? Realm()
                            var safeObjects = [T]()
                            references.forEach({ (reference) in
                                if let safeObject = realm?.resolve(reference){
                                    safeObjects.append(safeObject)
                                }
                            })
                            successHandler(nil, safeObjects)
                        }
                    }else{
                        DispatchQueue.main.async {
                            successHandler(nil, jsonArrayModel)
                        }
                    }
                    
                    break
                case .Default:
                    MKLog("no used responseType")
                    break
                }
            }
        }) { (request) in
            //将request.error中的信息处理到ErrorModel中
            let errModel = MKErrorModel("request error!")
            errModel.error = request.error
            failedHandler(errModel)
        }
    }
    
    /// 通过self.dataKey ，request.responseJson 获取json数据并返回
    ///
    /// - Parameter request: request
    /// - Returns: [String: Any] or [[String: Any]] or nil
    private func getJSONData(_ request: MKBaseRequest) -> Any?{
        guard let key = self.dataKey else {
            return request.responseJson
        }
        //解析key
        if key.contains(Character.init(".")){//keyPath
            return request.responseJson?[keyPath: KeyPath.init(key)]
        }else {//key
            return request.responseJson?[key]
        }
    }

    /// 通过request.responseJson获取网络请求失败后服务器返回错误信息
    ///
    /// - Parameter request: request
    /// - Returns: ErroModel
    private func getErrInfo(_ request: MKBaseRequest) -> MKErrorModel?{
        guard let json = request.responseJson, let errModel = Mapper<MKErrorModel>().map(JSON: json) else{
            return MKErrorModel("no responseJson!")
        }
        
        errModel.error = request.error
        return errModel
    }

    /// 将json数据转化为模型
    ///
    /// - Parameters:
    ///   - json: 输入的json数据
    ///   - modelType: 模型的类型
    /// - Returns: 模型对象
    private func getJSONModel<T: MKModel>(_ json: [String: Any], _ modelType:T.Type) -> T?{
        guard let jsonModel = Mapper<T>().map(JSON: json) else {
            return nil
        }
        
        if self.realm {
            return RealmManager.writeJSONToRealm(jsonModel)
        }
        return jsonModel
    }
    
    /// 将json数据转化模型数组
    ///
    /// - Parameters:
    ///   - jsonArray: 输入的jsonArray数据
    ///   - modelType: 模型的类型
    /// - Returns: 模型对象的数组
    private func getJSONArrayModel<T: MKModel>(_ jsonArray: [[String : Any]], _ modelType:T.Type) -> [T]?{
        let jsonArrayModel = Mapper<T>().mapArray(JSONArray: jsonArray)

        if jsonArrayModel.count == 0 {
            return nil
        }

        if self.realm {
            return RealmManager.writeJSONArrayToRealm(jsonArrayModel)
        }

        return jsonArrayModel
    }
    
    
    /// 请求失败的统一处理
    ///
    /// - Parameter err: errModel
    private func requestFailed(_ err:MKErrorModel?) -> Void{
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.requestFailedHandler?(err)
                self.requestFailedHandler = nil
            }
        }else {
            self.requestFailedHandler?(err)
            self.requestFailedHandler = nil
        }
    }
    
    
    /// 请求成功的统一处理，因为`self.requestSuccessHandler`未能成功声明为变量，（未实现 ）
    ///
    /// - Parameters:
    ///   - jsonModel: 模型对象
    ///   - jsonArrayModel: 模型对象数组
    private func requestSuccess<T: MKModel>(_ jsonModel: T?, _ jsonArrayModel: [T]?) -> Void{
//        if !Thread.isMainThread {
//            DispatchQueue.main.async {
//                self.requestSuccessHandler?(jsonModel, jsonArrayModel)
//                self.requestSuccessHandler = nil
//            }
//        }else {
//            self.requestSuccessHandler?(jsonModel, jsonArrayModel)
//            self.requestSuccessHandler = nil
//        }
        
    }
}
