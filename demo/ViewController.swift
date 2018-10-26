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
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var logTextView: UITextView!
    private var registerApi: RegisterApi? = nil
    private var loginApi: LoginApi? = nil
    private var accountApi: accountKitApi? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.logTextView.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        //account
//        self.startAccountKitApi()
        //chainrequest
//        self.startChainRequest()
        //batchrequest
//        self.startBatchRequest()
//        self.startSingleRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Action
    @IBAction func singleRequest(_ sender: UIButton) {
        self.startAccountKitApi()
    }
    @IBAction func batchRequest(_ sender: UIButton) {
        self.startBatchRequest()
    }
    @IBAction func chainRequest(_ sender: UIButton) {
        self.startChainRequest()
    }
    @IBAction func chainAndBatchRequest(_ sender: Any) {
        self.startRelyRequest()
    }
    @IBAction func testRequest(_ sender: UIButton) {
        
    }
    
    //MARK: - Api handler
    func startRelyRequest() {
        //组合接口请求
        let accountApi = accountKitApi()
        
        let accountBatchApi = accountKitApi()
        let refreshBatchApi = RefreshApi()
        let batchRequest = MKBatchRequest(MKRequests: [accountBatchApi,refreshBatchApi])
        
        batchRequest.setSingleCompletion({ (singleApi) in
            print("singleRequest success\(singleApi.requestURL)")
            self.appendTextLog("singleRequest success\(singleApi.requestURL)")
        }) { (singleApi) in
            print("singleRequest failed")
            self.appendTextLog("singleRequest failed")
        }
        
        batchRequest.set({ (batch) in
            print("batch success")
            self.appendTextLog("batch success")
        }) { (batch) in
            print("batch failed")
            self.appendTextLog("batch failed")
        }
        
        accountApi.getJsonDataWithCompletionHandler(UserModel.self, success: { (api, model) in
            print("Api success")
            self.appendTextLog("Api success")
            batchRequest.start()
        }) { (api, err) in
            
        }
        
    }
    
    func startBatchRequest() {
        let accountBatchApi = accountKitApi()
        accountBatchApi.delegate = self
        let accountBatchApi1 = accountKitApi()
        accountBatchApi1.delegate = self
        let accountBatchApi2 = accountKitApi()
        accountBatchApi2.delegate = self
        let refreshBatchApi = RefreshApi()
        let refreshBatchApi1 = RefreshApi()

        let batchRequest = MKBatchRequest(MKRequests: [accountBatchApi,refreshBatchApi, refreshBatchApi1,accountBatchApi1])
        batchRequest.delegate = self
        
        //batch start with setter
//        batchRequest.setSingleCompletion({ (singleApi) in
//            print("singleRequest success\(singleApi.requestURL)")
//        }) { (singleApi) in
//            print("singleRequest failed")
//        }
//
//        batchRequest.set({ (batch) in
//            print("batch success")
//        }) { (batch) in
//            print("batch failed")
//        }
//
//        batchRequest.start()
        
        //batch start with batchSuccess and batchFailed
//        batchRequest.start({ (batch) in
//            print("batch success")
//        }) { (batch) in
//            print("batch failed")
//        }
        
        //batch start with batchSuccess, batchFailed, singleSuccess and singleFailed
//        batchRequest.start({ (batch) in
//            print("batch success")
//            self.appendTextLog("batch success")
//        }, failure: { (batch) in
//            print("batch failed")
//            self.appendTextLog("batch failed")
//        }, singleSuccess: { (singleApi) in
//            print("singleRequest success\(singleApi.requestURL)")
//            self.appendTextLog("singleRequest success\(singleApi.requestURL)")
//        }) { (singleApi) in
//            print("singleRequest failed\(singleApi.requestURL)")
//            self.appendTextLog("singleRequest failed\(singleApi.requestURL)")
//        }
        
        //batch start with batchFinish, singleSuccess and singleFailed
        batchRequest.start(finish: { (batch) in
            self.appendTextLog("batch finish")
        }, singleSuccess: { (singleApi) in
            print("singleRequest success\(singleApi.requestURL)")
            self.appendTextLog("singleRequest success\(singleApi.requestURL)")
        }) { (singleApi) in
            print("singleRequest failed\(singleApi.requestURL)")
            self.appendTextLog("singleRequest failed\(singleApi.requestURL)")
        }
        
//        let person = OCPersion()
//        person.persionName("s", withId: "sss")
        
    }
    
    func startChainRequest() {
        //链式接口请求
        let chainRequest = MKChainRequest()
    
        let accountChainApi = accountKitApi()
        let registerChainApi = RegisterApi.init("sss", "sss")
//        chainRequest.add(accountChainApi)
        
        chainRequest.add(accountChainApi) { (chain, account) in
            print("chainRequest 1 block")
            self.appendTextLog("chainRequest 1 block, requestUrl :\(account.requestURL)")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 2 block")
            self.appendTextLog("chainRequest 2 block, requestUrl :\(regist.requestURL)")
        }
        
        chainRequest.add(registerChainApi) { (chain, regist) in
            print("chainRequest 3 block")
            self.appendTextLog("chainRequest 3 block, requestUrl :\(regist.requestURL)")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 4 block")
            self.appendTextLog("chainRequest 4 block, requestUrl :\(regist.requestURL)")
        }
        
        chainRequest.add(accountChainApi) { (chain, regist) in
            print("chainRequest 5 block")
            self.appendTextLog("chainRequest 5 block, requestUrl :\(regist.requestURL)")
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
//        self.accountApi?.getJsonDataWithCompletionHandler(UserModel.self, success: { (api, res) in
//            print("request success")
//        }, failed: { (api, errModel) in
//            print("request failed")
//        })
    }
    
    private func appendTextLog(_ textLog: String!){
//        var oldLog: String? = self.logTextView.text
//        oldLog?.append(textLog)
        self.logTextView.text.append("\n \(String(describing: textLog))")
    }
    
}

extension ViewController: MKBatchRequestProtocol{
    //MARK: - batch delegate
    func batchRequestDidFinished(_ batchRequest: MKBatchRequest) {
        print("batch delegate finish")
        self.appendTextLog("batch delegate finish")
    }
    
    func batchRequestDidSuccess(_ batchRequest: MKBatchRequest) {
        print("batch delegate success")
        self.appendTextLog("batch delegate success")
    }
    
    func batchRequestDidFailed(_ batchRequest: MKBatchRequest) {
        print("batch delegate failed")
        self.appendTextLog("batch delegate failed")
    }
}

extension ViewController: MKRequestProtocol{
    //MARK: - MKRequestProtocol
    func requestFinish(_ request: MKBaseRequest) {
        print("request success, requestUrl :\(request.requestURL)")
        self.appendTextLog("request delegate success, requestUrl :\(request.requestURL)")
    }
    
    func requestFailed(_ request: MKBaseRequest) {
        print("request failed, requestUrl :\(request.requestURL)")
        self.appendTextLog("request delegate failed, requestUrl :\(request.requestURL)")
    }
}

