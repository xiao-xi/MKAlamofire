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

class ViewController: UIViewController {

    private let registerApi: RegisterApi? = nil
    private let loginApi: LoginApi? = nil
    private var accountApi: accountKitApi? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
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
    
    func startChainRequest() {
        //链式接口请求
    }
    
    func startRegisterApi(_ phoneNum:String, _ code: String) {
        
    }

    func startLoginApi(_ phoneNum: String, _ pwd: String) {
        
    }
    
    func startAccountKitApi() {
        self.accountApi = accountKitApi()
        //
        self.accountApi?.getJsonDataWithCompletionHandler(UserModel.self) { (api, responseModel) in
            print("request finish!")
        }
    }
}

