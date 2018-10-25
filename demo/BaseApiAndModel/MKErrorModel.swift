//
//  MKErrorModel.swift
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import ObjectMapper
//public enum HTTPMethod: String {
//    case options = "OPTIONS"
//    case get     = "GET"
//    case head    = "HEAD"
//    case post    = "POST"
//    case put     = "PUT"
//    case patch   = "PATCH"
//    case delete  = "DELETE"
//    case trace   = "TRACE"
//    case connect = "CONNECT"
//}
enum MKErrorStatus : String{
    case Status_FORBIDDEN = "FORBIDDEN"
}

enum MKErrorCode : Int {
    case ErrorCode1 = 101101
    case ErrorCode2 = 101102
}

enum MKErrorType : String {
    case ErrorType_AuthException = "AuthException"
}

class MKErrorModel: MKModel {
    var timestamp: String?
    
    var error_message: String?
    
    var status: String?
    
    var error_code: MKErrorCode?
    
    var error_type: MKErrorType?
    
    override func mapping(map: Map) {
        timestamp <- map["timestamp"]
        error_message <- map["error_message"]
        status <- map["status"]
        error_code <- map["error_code"]
        error_type <- map["error_type"]
    }
}
