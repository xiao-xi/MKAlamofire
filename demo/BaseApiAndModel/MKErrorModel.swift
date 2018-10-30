//
//  MKErrorModel.swift
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper

//Status
enum MKErrorStatus : String{
    case Status_FORBIDDEN = "FORBIDDEN"
}

//ErrorCode
enum MKErrorCode : Int {
    case ErrorCode1 = 101101
    case ErrorCode2 = 101102
}

//ErrorType
enum MKErrorType : String {
    case ErrorType_AuthException = "AuthException"
}

//ErrorModel 属性与请求失败后返回的字段进行匹配
class MKErrorModel: MKModel {
    //时间戳
    var timestamp: String?
    
    //错误信息
    var error_message: String?
    
    //错误状态
    var status: String?
    
    //错误码
    var error_code: MKErrorCode?
    
    //错误类型
    var error_type: MKErrorType?
    
    //response.error Error
    var error: Error?
    
    required convenience init(_ message:String?) {
        self.init()
        self.error_message = message
    }
    
    override class func ignoredProperties() -> [String] {
        return ["error_type","error"]
    }
    
    //Map
    override func mapping(map: Map) {
        timestamp <- map["timestamp"]
        error_message <- map["error_message"]
        status <- map["status"]
        error_code <- map["error_code"]
        error_type <- map["error_type"]
    }
}
