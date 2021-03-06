//
//  BaseRequest.swift
//  MKAgent
//
//  Created by zwb on 2017/12/27.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation
import Alamofire

/// the request priority
/// 网络请求优先级别
///
/// - `default`: the default
/// - low: the lower
/// - high: the highest
public enum MKRequestPriority: Int8 {
    case `default` = 0
    case low = -4
    case high = 4
}

/// the request returns the data type
/// 网络请求返回类型
///
/// - `default`: default is Data
/// - json: JSON
/// - string: String
/// - data: Data
/// - plist: Plist
public enum MKResponseType: Int8 {
    case `default`, json, string, data, plist
}

/// the request need to call the method
/// 网络请求方式
///
/// - options: "OPTIONS"
/// - get: "GET"
/// - head: "HEAD"
/// - post: "POST"
/// - put: "PUT"
/// - patch: "PATCH"
/// - delete: "DELETE"
/// - trace: "TRACE"
/// - connect: "CONNECT"
public enum MKHTTPMethod {
    
    case options, get, head, post, put, patch, delete, trace, connect
    
    public init(rawValue: HTTPMethod) {
        switch rawValue {
        case HTTPMethod.options:  self = .options
        case HTTPMethod.get:      self = .get
        case HTTPMethod.head:     self = .head
        case HTTPMethod.post:     self = .post
        case HTTPMethod.put:      self = .put
        case HTTPMethod.patch:    self = .patch
        case HTTPMethod.delete:   self = .delete
        case HTTPMethod.trace:    self = .trace
        case HTTPMethod.connect:  self = .connect
        }
    }
    
    public var rawValue: HTTPMethod {
        switch self {
        case .options: return HTTPMethod.options
        case .get:     return HTTPMethod.get
        case .head:    return HTTPMethod.head
        case .post:    return HTTPMethod.post
        case .put:     return HTTPMethod.put
        case .patch:   return HTTPMethod.patch
        case .delete:  return HTTPMethod.delete
        case .trace:   return HTTPMethod.trace
        case .connect: return HTTPMethod.connect
        }
    }
}

/// parameter encoding
/// 网络请求参数编码方式
///
/// - json: JSONEncoding
/// - url: URLEncoding
/// - plist: PropertyListEncoding
public enum MKParameterEncoding {
    case json, url, plist
    
    public init(rawValue: ParameterEncoding) {
        switch rawValue {
        case is JSONEncoding:
            self = .json
        case is URLEncoding:
            self = .url
        case is PropertyListEncoding:
            self = .plist
        default: self = .url
        }
    }
    
    public var rawValue: ParameterEncoding {
        switch self {
        case .url:   return URLEncoding.default
        case .json:  return JSONEncoding.default
        case .plist: return PropertyListEncoding.default
        }
    }
}

// MARK:  - MKRequestProtocol

///=============================================================================
/// @name MKRequestProtocol
///=============================================================================

/// Request Protoclo
///  The MKRequestProtocol protocol defines several optional methods you can use
///  to receive network-related messages. All the delegate methods will be called
///  on the main queue.
public protocol MKRequestProtocol : class {
    
    ///  The request finish
    ///  Tell the delegate that the request has finished successfully.
    /// 网络请求结束触发
    ///
    ///  @param request The corresponding request.
    func requestFinish(_ request:MKBaseRequest) -> Void
    
    /// The request failed
    ///  Tell the delegate that the request has failed.
    ///  网络请求失败触发
    ///
    ///  @param request The corresponding request.
    func requestFailed(_ request:MKBaseRequest) -> Void
}

extension MKRequestProtocol {
    public func requestFinish(_ request:MKBaseRequest) -> Void{}
    
    public func requestFailed(_ request:MKBaseRequest) -> Void{}
}

// MARK:  - MKRequestAccessoryProtocol

///=============================================================================
/// @name MKRequestAccessoryProtocol
///=============================================================================

/// AlRequest Protocol
///  The MKRequestAccessoryProtocol protocol defines several optional methods that can be
///  used to track the status of a request. Objects that conforms this protocol
///  ("accessories") can perform additional configurations accordingly. All the
///  accessory methods will be called on the main queue.
public protocol MKRequestAccessoryProtocol {
    
    /// the request will to begin
    ///  Inform the accessory that the request is about to start.
    /// 网络请求即将开始
    ///
    ///  @param request The corresponding request. MKRequest, MKChainRequest, MKBatchRequest
    func requestWillStart(_ request: Any) -> Void
    
    /// the request will to end
    ///  Inform the accessory that the request is about to stop. This method is called
    ///  before executing `requestFinished` and `successCompletionBlock`.
    /// 网络请求即将结束
    ///
    ///  @param request The corresponding request. MKRequest, MKChainRequest, MKBatchRequest
    func requestWillStop(_ request: Any) -> Void
    
    /// the request has come to an end
    ///  Inform the accessory that the request has already stoped. This method is called
    ///  after executing `requestFinished` and `successCompletionBlock`.
    /// 网络请求已经结束
    ///
    ///  @param request The corresponding request. MKRequest, MKChainRequest, MKBatchRequest
    func requestDidStop(_ request: Any) -> Void
}

// MARK:  - BaseRequest

///=============================================================================
/// @name BaseRequest
///=============================================================================

/// Base protocol
///  BaseRequest is the abstract class of network request. It provides many options
///  for constructing request. It's the base class of `MKRequest`.
public protocol MKBaseRequestProcotol {
    
    /// 上传数据时的closure
    /// A closure for upload data
    typealias MKMutableDataClosure = (_ data:MultipartFormData) -> Void
    
    /// 网络请求完成的closure
    /// A closure for request finish
    typealias MKRequestCompleteClosure = (_ request:MKBaseRequest) -> Void
    
    /// A dictionary of headers to apply to a `URLRequest`.
    typealias MKHTTPHeaders = [String: String]
    
///=============================================================================
/// @name Request Information
///=============================================================================
    
// MARK:  - SubClass Override
    
///=============================================================================
/// @name Subclass Override
///=============================================================================
    
    /// 需要更改baseURL时调用
    ///  The baseURL of request. This should only contain the host part of URL, e.g., http://www.example.com.
    ///  See also `requestURL`
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var baseURL: String { get }
    
    /// 每一个model请求的url
    ///  The URL path of request. This should only contain the path part of URL, e.g., /v1/user. See alse `baseURL`.
    ///
    ///  @discussion This will be concated with `baseURL` using [NSURL URLWithString:relativeToURL].
    ///  Because of this, it is recommended that the usage should stick to rules stated above.
    ///  Otherwise the result URL may not be correctly formed. See also `URLString:relativeToURL`
    ///  for more information.
    ///
    ///  Additionaly, if `requestURL` itself is a valid URL, it will be used as the result URL and
    ///  `baseURL` will be ignored.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestURL: String { get }
    
    /// 需要使用cdnURL时调用
    ///  Optional CDN URL for request.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var cdnURL: String { get }
    
    /// 请求的method
    ///  HTTP request method.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestMethod: MKHTTPMethod { get }
    
    /// 需要添加的请求头
    ///  Additional HTTP request header field.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestHeaders: MKHTTPHeaders? { get }
    
    /// 需要添加的请求参数
    ///  Additional request argument.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestParams: [String: Any]? { get }
    
    /// 请求时param编码
    ///  Request serializer type.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var paramEncoding: MKParameterEncoding { get }
    
    /// 请求返回的数据类型
    ///  Response serializer type. See also `responseObject`.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var responseType: MKResponseType { get }
    
    /// 请求的优先权
    ///  The priority of the request. Effective only on iOS 8+. Default is `MKRequestPriority.default`.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var priority: MKRequestPriority? { get }
    
    // 上传文件时以下面三种任选一种作为上传数据依据
    /// 上传文件时上传的数据
    ///  This can be use to construct HTTP body when needed in POST request. Default is nil.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestDataClosure: MKMutableDataClosure? { get }
    
    /// 上传文件时文件的url
    ///  This can be use to construct HTTP body when needed in POST request. Default is nil.
    ///  If you want to upload a local file, you can use a local URL to upload this file.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var uploadFile: URL? { get }
    
    /// 上传文件时文件的data
    ///  This can be use to construct HTTP body when needed in POST request. Default is nil.
    ///  If you want to upload local data, you can use a local data to upload this data.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var uploadData: Data? { get }
    
    /// 下载文件保存的名字，默认存放在 .../Documents/{MKConfig.shared.downFileName}/...下
    ///  This value is used to perform resumable download request. Default is nil.
    ///  And the file save in .../Documents/{MKConfig.shared.downFileName}.
    ///
    ///  @discussion NSURLSessionDownloadTask is used when this value is not nil.
    ///   The exist file at the path will be removed before the request starts. If request succeed, file will
    ///   be saved to this path automatically, otherwise the response will be saved to `responseData`
    ///   and `responseString`. For this to work, server must support `Range` and response with
    ///   proper `Last-Modified` and/or `Etag`. See `NSURLSessionDownloadTask` for more detail.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var resumableDownloadPath: String { get }
    
    /// https时使用的证书的用户名以及密码, first is user, last is password.
    ///  Username and password used for HTTP authorization. Should be formed as @[@"Username", @"Password"].
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var requestAuthHeaders: [String]? { get }
    
    /// 是否使用cdn
    ///  Should use CDN when sending request.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var useCDN: Bool { get }
    
///=============================================================================
/// @name  Response Information
///=============================================================================
    
// MARK: - Response Properties
    
    /// 响应状态码
    ///  The response status code.
    @available(iOS 8.0, watchOS 2.0, tvOS 9.0, OSX 10.10, *)
    var statusCode: Int { get }
}
