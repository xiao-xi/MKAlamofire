//
//  ViewController.swift
//  demo
//
//  Created by holla on 2018/10/23.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ViewController: UIViewController, MKBatchRequestProtocol, MKRequestProtocol {

    private var registerApi: RegisterApi? = nil
    private var loginApi: LoginApi? = nil
    private var accountApi: accountKitApi? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        //account
//        self.startAccountKitApi()
        //chainrequest
//        self.startChainRequest()
        //batchrequest
        self.startBatchRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Api handler
    func startSingleRequest() {
        //单个接口请求
    }
    
    func startBatchRequest() {
        let accountBatchApi = accountKitApi()
        accountBatchApi.delegate = self
        let accountBatchApi1 = accountKitApi()
        accountBatchApi1.delegate = self
        let accountBatchApi2 = accountKitApi()
        accountBatchApi2.delegate = self
        let registerBatchApi = RegisterApi.init("sss", "sss")
        
        let loginBatchApi = LoginApi.init("sss", "sss")
        
        let batchRequest = MKBatchRequest(MKRequests: [accountBatchApi, accountBatchApi1, accountBatchApi2])
        batchRequest.delegate = self
        batchRequest.start({ (batch) in
            print("batch success")
        }) { (batch) in
            print("batch failed")
        }
    }
    
    func startChainRequest() {
        //链式接口请求
        let chainRequest = MKChainRequest()
    
        let accountChainApi = accountKitApi()
        let registerChainApi = RegisterApi.init("sss", "sss")
//        chainRequest.add(accountChainApi)
        
        chainRequest.add(accountChainApi) { (chain, account) in
            print("chainRequest 1 block")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 2 block")
        }
        
        chainRequest.add(registerChainApi) { (chain, regist) in
            print("chainRequest 3 block")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 4 block")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 5 block")
        }
        chainRequest.start()
    }
    
    func startRegisterApi(_ phoneNum:String, _ code: String) {
        
    }

    func startLoginApi(_ phoneNum: String, _ pwd: String) {
        UserDefaults.standard.set("Authorization value", forKey: "Authorization")
        let value = UserDefaults.standard.string(forKey: "Authorization")
        print("Authorization value: \(String(describing: value))")
    }
    
    func startAccountKitApi() {
        self.accountApi = accountKitApi()
        self.accountApi?.getJsonDataWithCompletionHandler(UserModel.self, success: { (api, res) in
            print("request success")
        }, failed: { (api, errModel) in
            print("request failed")
        })
    }
    
    //MARK: - batch delegate
    func batchRequestDidFinished(_ batchRequest: MKBatchRequest) {
        print("delegate finish")
    }
    
    func batchRequestDidFailed(_ batchRequest: MKBatchRequest) {
        print("delegate failed")
    }
    
    //MARK: - MKRequestProtocol
    func requestFinish(_ request: MKBaseRequest) {
        print("request success, requestUrl :\(request.requestURL)")
    }
    func requestFailed(_ request: MKBaseRequest) {
        print("request failed, requestUrl :\(request.requestURL)")
    }
}

