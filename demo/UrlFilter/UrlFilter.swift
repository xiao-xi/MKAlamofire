//
//  UrlFilter.swift
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

class UrlFilter: MKURLFilterProtocol {
    func filterURL(_ originURL: String, baseRequest request: MKBaseRequest) -> String {
//        print("origin url: \(originURL),requestUrl:\(request.requestURL), param: \(String(describing: request.requestParams))")
        return originURL
    }
}
