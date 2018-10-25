//
//  Environment.swift
//  demo
//
//  Created by holla on 2018/10/25.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

struct Environment {
    static let bundleId = "cool.monkey.ios"
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0" // Use zeros instead of crashing. This should not happen.
    }
    
    static var authorization: String?
}
