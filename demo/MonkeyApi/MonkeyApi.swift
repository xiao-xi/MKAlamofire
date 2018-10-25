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


