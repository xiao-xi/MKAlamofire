//
//  MonkeyApi.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

class RegisterApi: MKApiRequest {
    var phoneNum: String!
    var code: String!
    init(_ phoneNum: String, _ code:String) {
        self.phoneNum = phoneNum
        self.code = code
    }
    override var requestURL: String{
        return "monkey/register"
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.post
    }
}

class LoginApi: MKApiRequest {
    
    var phoneNum: String! = ""
    var pwd: String! = ""
    
    init(_ phoneNum:String, _ pwd: String) {
        self.phoneNum = phoneNum
        self.pwd = pwd
    }
    
    
    override var requestURL: String{
        return "www.baidu.com"
    }
    
//    override var requestParams: [String : Any]?{
//        return
//    }
}

class accountKitApi: MKApiRequest {
    
    override var needRealm: Bool{
        return true
    }
    
    override var requestURL: String{
        return "v1.0/auth/accountkit"
    }
    
    override var requestParams: [String : Any]?{
        return ["accountkit_token": "EMAWcG5IBrNptROARO97amymmaLtQFZCVQFVRL24TyJXWlKkXEcVGXWFsQmvTMFuhTuM1xIw7i2sUHGbhFZBGtiZCs9i0w4fwZB5oyFv8DnwZDZD"]
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.post
    }
    
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.json
    }
}

class RefreshApi: MKApiRequest {
    override var requestURL: String{
        return "v2/auth/refresh"
    }
    
    override var requestHeaders: MKHTTPHeaders?{
        let client = Environment.bundleId
        let version = Environment.appVersion
        let headerDic = [
            "Device":"iOS",
            "Accept":"application/vnd.api+json, application/json",
            "Content-Type":"application/vnd.api+json",
            "Version":version,
            "Client":client,
            "Authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1MjY1NTM1LCJzdWIiOiI1MjY1NTM1IiwiaWF0IjoxNTQwNDYxMjYwLCJleHAiOjE1NDgyMzcyNjB9.vGHvKoMTiQ8DAiHu6aQ6R9UGZVXX11vDfpoGgF_BQNM"
        ]
        return headerDic
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.post
    }
    
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.json
    }
}


