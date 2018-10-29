//
//  MKConfig.swift
//  MKAgent
//
//  Created by zwb on 17/3/24.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation
import Alamofire

///  MKURLFilterProtocol can be used to append common parameters to requests before sending them.
public protocol MKURLFilterProtocol {
    /// Preprocess request URL before actually sending them.
    ///
    /// - Parameters:
    ///   - originURL: request's origin URL, which is returned by `requestUrl`
    ///   - request: request itself
    /// - Returns: A new url which will be used as a new `requestUrl`
    func filterURL(_ originURL: String, baseRequest request: MKBaseRequest) -> String
}

///  MKCacheDirPathFilterProtocol can be used to append common path components when caching response results
public protocol MKCacheDirPathFilterProtocol {
    /// Preprocess cache path before actually saving them.
    ///
    /// - Parameters:
    ///   - originPath: original base cache path, which is generated in `MKBaseRequest` class.
    ///   - request: request itself
    /// - Returns: A new path which will be used as base path when caching.
    func filterCacheDirPath(_ originPath: String, baseRequest request: MKBaseRequest) -> String
}

///  MKConfig stored global network-related configurations, which will be used in `MKAgent`
///  to form and filter requests, as well as caching response.
public final class MKConfig {
    
    ///  Return a shared config object.
    public static let shared = MKConfig()
    
// MARK: - Public Properties
    
///=============================================================================
/// @name Public Properties
///=============================================================================
    
    /// 配置项目的baseURL
    ///  Request base URL, such as "http://www.baidu.com". Default is empty string.
    public var baseURL: String
    
    /// 配置项目的cdnURL
    ///  Request CDN URL. Default is empty string.
    public var cdnURL: String
    
    /// 网络请求超时时间, Default 30s
    /// Request time out interval. Default is 30s.
    public var requestTimeoutInterval: TimeInterval
    
    /// 设置响应状态码的范围, 默认为(200-300)
    /// Request vaildator code. Default is 200~300.
    public var statusCode: [Int]
    
    /// 设置返回接受类型
    /// Set to return to accept type
    public var acceptType: [String]
    
    /// 是否能通过蜂窝网络访问数据, Default true
    /// Whether allow cellular. Default is true.
    public var allowsCellularAccess: Bool
    
    /// 是否开启日志打印，默认false
    ///  Whether to log debug info. Default is NO.
    public var debugLogEnable: Bool
    
    /// 是否开启监听网络，默认true
    /// Whether public network monitoring. Default is true.
    public var listenNetWork: Bool
    
    /// url protocol协议组
    ///  URL filters. See also `MKURLFilterProtocol`.
    public var urlFilters: [MKURLFilterProtocol]
    
    /// cache dirpath protocol 协议组
    ///  Cache path filters. See also `MKCacheDirPathFilterProtocol`.
    public var cacheDirPathFilters: [MKCacheDirPathFilterProtocol]
    
    ///  serverPolicy will be used to Alamofire. Default nil.
    ///  Security policy will be used by Alamofire. See also `ServerTrustPolicyManager`.
    public var serverPolicy: ServerTrustPolicyManager?
    
    ///  SessionConfiguration will be used to Alamofire.
    public var sessionConfiguration: URLSessionConfiguration
    
    ///  缓存请求文件的文件夹名, 位于`/Library/Caches/{cacheFileName}`
    /// Save to disk file name.
    public var cacheFileName = "MKAgent.request.cache.default"
    
    /// 下载文件时保存的文件名, 位于`/Library/Caches/{downFileName}`下
    /// Download file name
    public var downFileName = "MKAgent.download.default"
    
// MARK: - Cycle Life
    
///=============================================================================
/// @name Cycle Life
///=============================================================================
    
    public init() {
        self.baseURL = ""
        self.cdnURL = ""
        self.requestTimeoutInterval = 30
        self.statusCode = Array(200..<300)
        self.acceptType = ["application/json", "text/json", "text/javascript", "text/html", "text/plain", "image/jpeg"]
        self.allowsCellularAccess = true
        self.debugLogEnable = false
        self.listenNetWork = true
        self.serverPolicy = nil
        self.urlFilters = [MKURLFilterProtocol]()
        self.cacheDirPathFilters = [MKCacheDirPathFilterProtocol]()
        self.sessionConfiguration = .default
    }
    
    public init(baseURL:String = "", cdnURL: String = "", requestTimeoutInterval:TimeInterval = 30, statusCode:[Int] = Array(200..<300), acceptType: [String] = ["application/json"], allowsCellularAccess:Bool = true, debugLogEnable:Bool = false, listenNetWork:Bool = true, serverPolicy:ServerTrustPolicyManager? = nil , urlFilters: [MKURLFilterProtocol] = [], cacheDirPathFilters: [MKCacheDirPathFilterProtocol] = [], sessionConfiguration:URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.cdnURL = cdnURL
        self.requestTimeoutInterval = requestTimeoutInterval
        self.statusCode = statusCode
        self.acceptType = acceptType
        self.allowsCellularAccess = allowsCellularAccess
        self.debugLogEnable = debugLogEnable
        self.listenNetWork = listenNetWork
        self.serverPolicy = serverPolicy
        self.urlFilters = urlFilters
        self.cacheDirPathFilters = cacheDirPathFilters
        self.sessionConfiguration = sessionConfiguration
    }
    
// MARK: - Public
    
///=============================================================================
/// @name Public
///=============================================================================
    
    ///  Add a new URL filter.
    public func add(_ urlFilter: MKURLFilterProtocol) {
        urlFilters.append(urlFilter)
    }
    
    ///  Add a new cache path filter
    public func add(_ cacheFilter: MKCacheDirPathFilterProtocol) {
        cacheDirPathFilters.append(cacheFilter)
    }
    
    ///  Remove all URL filters.
    public func cleanURLFilters() -> Void {
        urlFilters.removeAll()
    }
    
    ///  Clear all cache path filters.
    public func cleanCacheFilters() -> Void {
        cacheDirPathFilters.removeAll()
    }
}

// MARK: - Description

///=============================================================================
/// @name Description
///=============================================================================

extension MKConfig : CustomStringConvertible {
    public var description: String {
        return String(format: "<%@: %p>{ bseURL: %@ } { cdnURL: %@ }", #file, #function, baseURL, cdnURL)
    }
}

// MARK: - Debug Description

///=============================================================================
/// @name Debug Description
///=============================================================================

extension MKConfig : CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(format: "<%@: %p>{ bseURL: %@ } { cdnURL: %@ }", #file, #function, baseURL, cdnURL)
    }
}

// MARK: - GCD

///=============================================================================
/// @name GCD
///=============================================================================

extension DispatchQueue {
    public static var mkCurrent: DispatchQueue {
        let name = String(format: "com.MKAgent.request.%08x%08x", arc4random(),arc4random())
        return DispatchQueue(label: name, attributes: .concurrent)
    }
}

// MARK: - Print Logs

///=============================================================================
/// @name Print Logs
///=============================================================================

public func MKLog<T>(_ message:T, file File:NSString = #file, method Method:String = #function, line Line:Int = #line) -> Void {
    if MKConfig.shared.debugLogEnable {
        #if DEBUG
            print("<\(File.lastPathComponent)>{Line:\(Line)}-[\(Method)]:\(message)")
        #endif
    }
}

public func MKLog(_ message:String) -> Void {
    if MKConfig.shared.debugLogEnable {
        #if DEBUG
        print(message)
        #endif
    }
}
