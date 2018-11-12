//
//  MonkeyApi.swift
//  demo
//
//  Created by holla on 2018/10/24.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import Alamofire

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
    
    override var realm: Bool{
        return true
    }
    
    
    override var requestURL: String{
        return "v1.0/auth/accountkit"
    }
    
    override var requestParams: [String : Any]?{
        return ["accountkit_token": "EMAWfCmBTEmoU3rDSa7JFo5enuqmJs86wdZCKH53bfFXxwZASvpJZAc2h4jGhipZC9SFPzSXGpOyqCfKZCTLE38dUNlJsox3CI8gdBbHEgXoQZDZD"]
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.post
    }
    
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.json
    }
    
    override var dataKey:String? {
        return "data.attributes"
    }
}

class RefreshApi: MKApiRequest {
    
    override var realm: Bool{
        return true
    }
    
    override var dataKey :String? {
        return nil
    }
    
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

class FriendShipsApi: MKApiRequest {
    override var realm: Bool{
        return true
    }
    
    override var requestURL: String{
//        https://api.monkey.cool/api/v2/friendships/
        return "v2/friendships"
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
            "Authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozNzI0ODIzLCJzdWIiOiIzNzI0ODIzIiwiaWF0IjoxNTQwODc3NTMwLCJleHAiOjE1NDYwNjE1MzB9.GRdGu4qSpEZqk4CHCRiLTyHqokwPYIHaJsA5eoAMYXE"
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




