//
//  MonkeyApi.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

class RegisterApi: BaseApiRequest {
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

class LoginApi: BaseApiRequest {
    
    var phoneNum: String! = ""
    var pwd: String! = ""
    
    init(_ phoneNum:String, _ pwd: String) {
        self.phoneNum = phoneNum
        self.pwd = pwd
    }
    
    override var requestURL: String{
        return "www.baidu.com"
    }
}

class accountKitApi: BaseApiRequest {
    
    override var needRealm: Bool{
        return true
    }
    
    override var requestURL: String{
        return "http://test.monkey.cool/api/v1.0/auth/accountkit"
    }
    
    override var requestHeaders: MKHTTPHeaders?{
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


