//
//  MKBatchRequest.swift
//  MKAgent
//
//  Created by zwb on 17/3/31.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

///  MKBatchRequest can be used to batch several MKRequest. Note that when
///  used inside MKBatchRequest, a single MKRequest will have its own callback
///  and delegate cleared, in favor of the batch request callback.
public final class MKBatchRequest {
    
    public typealias MKBatchRequestClosure = (_ batchRequest: MKBatchRequest) -> Void

// MARK: - Public Properties
    
///=============================================================================
/// @name Public Properties
///=============================================================================

    /// 所有的并列请求.
    ///  All the requests are stored in this array.
    public private(set) var requests: [MKBaseRequest]
    
    /// 响应delegate
    ///  The delegate object of the batch request. Default is nil.
    public weak var delegate: MKBatchRequestProtocol?
    
    /// 网络请求的协议组
    ///  This can be used to add several accossories object. Note if you use `add(_ requestAccessory)` to add acceesory
    ///  this array will be automatically created. Default is nil.
    public private(set) var requestAccessories: [MKRequestAccessoryProtocol]?
    
    //所有请求成功的数量
    public var successCount: Int = 0
    
    //所有成功的数组
    public var successRequests: [MKBaseRequest]
    
    //所有请求失败的数量
    public var failedCount:Int = 0
    
    //请求失败的数组
    public var failedRequests: [MKBaseRequest]
    
    ///  batch request identify. Default 0.
    ///  Tag can be used to identify batch request. Default value is 0.
    public var tag: Int
    
    /// 请求结束回调，无论是否存在失败的请求
    ///  The success callback. Note this will be called only if all the requests are finished.
    ///  This block will be called on the main queue.
    public var finishCompleteClosure: MKBatchRequestClosure?
    
    /// 请求成功回调，全部成功
    ///  The success callback. Note this will be called only if all the requests are finished.
    ///  This block will be called on the main queue.
    public var successCompleteClosure: MKBatchRequestClosure?
    
    /// 请求失败回调，存在失败的请求
    ///  The failure callback. Note this will be called if one of the requests fails.
    ///  This block will be called on the main queue.
    public var failureCompleteClosure: MKBatchRequestClosure?
    
    //单个接口的回调
    public var singleRequestFinish: MKBaseRequestProcotol.MKRequestCompleteClosure?
    //单个接口的回调失败回调
    public var singleRequestFailed: MKBaseRequestProcotol.MKRequestCompleteClosure?
    
// MARK: - Private Properties
    
///=============================================================================
/// @name Private Properties
///=============================================================================

    fileprivate var _finishCount: Int
    public private(set) var rawString: String
    
// MARK: - Cycle Life
    
///=============================================================================
/// @name Cycle Life
///=============================================================================
    
    /// Creates a `MKBatchRequest` with a bunch of requests.
    ///
    /// - Parameter MKRequests: requests useds to create batch request.
    public init(MKRequests: [MKBaseRequest] ) {
        requests = MKRequests
        _finishCount = 0
        tag = 0
        rawString = UUID().uuidString
        successRequests = []
        failedRequests = []
    }
    
// MARK: - Start Action
    
///=============================================================================
/// @name Start Action
///=============================================================================
    
    ///  Append all the requests to queue.
    public func start() -> Void {
        if _finishCount > 0 {
            MKLog("Batch Error! batch request has already started.")
            return
        }
        self.successRequests = []
        self.failedRequests = []
        MKBatchAlamofire.shared.add(self)
        self.totalAccessoriesWillStart()
        requests.forEach {
            $0.delegate = self
            $0.clearCompleteClosure()
            $0.start()
        }
    }
    
    ///  Stop all the requests of the batch request.
    public func stop() -> Void {
        self.totalAccessoriesWillStop()
        self.delegate = nil
        self.cleanRequest()
        
        self.totalAccessoriesDidStop()
        MKBatchAlamofire.shared.remove(self)
    }
    
    ///  Convenience method to start the batch request with block callbacks.
    public func start(_ success: MKBatchRequestClosure?, failure failureClosure: MKBatchRequestClosure?) {
        self.start(success, failure: failureClosure, singleSuccess: nil, singleFailure: nil)
    }
    
    ///  Convenience method to start the batch request with block callbacks when only finsh adn single request with block callbacks.
    public func start(finish finishClosure: MKBatchRequestClosure?,singleSuccess singleSuccessClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?, singleFailure singleFailureClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?){
        self.set(finishClosure)
        self.setSingleCompletion(singleSuccessClosure, failure: singleFailureClosure)
        self.start()
    }
    
    ///  Convenience method to start the batch request with block callbacks adn single request with block callbacks.
    public func start(_ success: MKBatchRequestClosure?, failure failureClosure: MKBatchRequestClosure?,singleSuccess singleSuccessClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?, singleFailure singleFailureClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?) {
        self.set(success, failure: failureClosure)
        self.setSingleCompletion(singleSuccessClosure, failure: singleFailureClosure)
        self.start()
    }
    
    ///  Convenience method to add request accessory. See also `requestAccessories`.
    public func add(_ requestAccessory: MKRequestAccessoryProtocol) {
        if requestAccessories == nil {
            requestAccessories = [MKRequestAccessoryProtocol]()
        }
        requestAccessories?.append(requestAccessory)
    }
    
    public func set(_ finish: MKBatchRequestClosure?){
        self.finishCompleteClosure = finish
    }
    
    ///  Set batchRequest completion callbacks
    public func set(_ success: MKBatchRequestClosure?, failure failureClosure: MKBatchRequestClosure?) {
        self.successCompleteClosure = success
        self.failureCompleteClosure = failureClosure
    }
    ///  Set requests completion callbacks
    public func setSingleCompletion(_ singleSuccessClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?, failure singleFailureClosure: MKBaseRequestProcotol.MKRequestCompleteClosure?){
        self.singleRequestFinish = singleSuccessClosure
        self.singleRequestFailed = singleFailureClosure
    }
    
    ///  Nil out both success and failure callback blocks.
    public func cleanCompleteClosre() -> Void {
        // nil out to break the retain cycle.
        self.finishCompleteClosure = nil
        self.successCompleteClosure = nil
        self.failureCompleteClosure = nil
        self.singleRequestFinish = nil
        self.singleRequestFailed = nil
    }
    
// MARK: - Private
    
///=============================================================================
/// @name Private
///=============================================================================
    
    private func cleanRequest() -> Void {
        requests.forEach { $0.stop() }
        self.cleanCompleteClosre()
    }
    
    deinit {
        self.cleanRequest()
    }
}

// MARK: - MKRequestAccessoryProtocol

///=============================================================================
/// @name MKRequestAccessoryProtocol
///=============================================================================

extension MKBatchRequest {
    
    func totalAccessoriesWillStart() -> Void {
        if let accessoris = self.requestAccessories {
            for accessory in accessoris {
                accessory.requestWillStart(self)
            }
        }
    }
    
    func totalAccessoriesWillStop() -> Void {
        if let accessoris = self.requestAccessories {
            for accessory in accessoris {
                accessory.requestWillStop(self)
            }
        }
    }
    
    func totalAccessoriesDidStop() -> Void {
        if let accessoris = self.requestAccessories {
            for accessory in accessoris {
                accessory.requestDidStop(self)
            }
        }
    }
}

// MARK: - Request Protocol

///=============================================================================
/// @name Request Protocol
///=============================================================================

extension MKBatchRequest : MKRequestProtocol {
    
    public func requestFinish(_ request: MKBaseRequest) {
        self.singleRequestFinish?(request)
        successCount += 1
        _finishCount += 1
        successRequests.append(request)
        if _finishCount == requests.count {
            self.totalAccessoriesWillStop()
            
            if let delegate = delegate {
                delegate.batchRequestDidSuccess(self)
                delegate.batchRequestDidFinished(self)
            }
            if let closure = successCompleteClosure {
                closure(self)
            }
            
            if let closure = finishCompleteClosure {
                closure(self)
            }
            
            self.cleanCompleteClosre()
            
            self.totalAccessoriesDidStop()
            MKBatchAlamofire.shared.remove(self)
        }
    }
    
    public func requestFailed(_ request: MKBaseRequest) {
        self.singleRequestFailed?(request)
        
        failedCount += 1    //失败次数+1
        _finishCount += 1   //无论成功或者失败都属于完成
        failedRequests.append(request)
        if _finishCount == requests.count { //所有的请求都已经完成时结束
            self.totalAccessoriesWillStop()
            
            // call back
            if let delegate = delegate {
                delegate.batchRequestDidFailed(self)
                delegate.batchRequestDidFinished(self)
            }
            
            if let closure = failureCompleteClosure {
                closure(self)
            }
            
            if let closure = finishCompleteClosure {
                closure(self)
            }
            
            // clean
            self.cleanCompleteClosre()
            
            self.totalAccessoriesDidStop()
            MKBatchAlamofire.shared.remove(self)
        }
        
    }
}

// MARK: - MKBatchRequestProtocol

///=============================================================================
/// @name MKBatchRequestProtocol
///=============================================================================

/// Batch request protocol
///  The MKBatchRequestProtocol protocol defines several optional methods you can use
///  to receive network-related messages. All the delegate methods will be called
///  on the main queue. Note the delegate methods will be called when all the requests
///  of batch request finishes.
public protocol MKBatchRequestProtocol : class {
    
    ///  Tell the delegate that the batch request has finished successfully/
    /// 并式请求全部结束
    ///
    ///  @param batchRequest The corresponding batch request.
    func batchRequestDidFinished(_ batchRequest: MKBatchRequest) -> Void
    
    /// 并式请求全部成功
    ///
    ///  @param batchRequest The corresponding batch request
    func batchRequestDidSuccess(_ batchRequest: MKBatchRequest) -> Void
    
    ///  Tell the delegate that the batch request has failed.
    /// 并式请求全部请求中存在失败的请求
    ///
    ///  @param batchRequest The corresponding batch request.
    func batchRequestDidFailed(_ batchRequest: MKBatchRequest) -> Void
}

extension MKBatchRequestProtocol {
    public func batchRequestDidFinished(_ batchRequest: MKBatchRequest) -> Void{}
    
    public func batchRequestDidFailed(_ batchRequest: MKBatchRequest) -> Void{}
}

// MARK: - MKBatchAlamofire

///=============================================================================
/// @name MKBatchAlamofire
///=============================================================================

///  MKBatchAlamofire handles batch request management. It keeps track of all
///  the batch requests.
public final class MKBatchAlamofire {
    
    ///  Get the shared batch request.
    public static let shared = MKBatchAlamofire()

// MARK: - Private Properties
    
///=============================================================================
/// @name Private Properties
///=============================================================================
    
    private let _lock: NSLock
    private var _batchRequests: [MKBatchRequest]
    
// MARK: - Cycle Life
    
///=============================================================================
/// @name Cycle Life
///=============================================================================
    
    public init() {
        _lock = NSLock()
        _batchRequests = [MKBatchRequest]()
    }
    
// MARK: - Public
    
///=============================================================================
/// @name Public
///=============================================================================
    
    ///  Add a batch request.
    public func add(_ batchRequest: MKBatchRequest) {
        _lock.lock()
        defer { _lock.unlock() }
        _batchRequests.append(batchRequest)
    }
    
    ///  Remove a previously added batch request.
    public func remove(_ batchRequest: MKBatchRequest) {
        _lock.lock()
        defer { _lock.unlock() }
        let index = _batchRequests.index(where: { $0 == batchRequest })
        if let index = index {
            _batchRequests.remove(at: index)
        }
    }
}

extension MKBatchRequest : Equatable {}

/// Overloaded operators
public func ==(
    lhs: MKBatchRequest,
    rhs: MKBatchRequest)
    -> Bool
{
    return lhs.rawString == rhs.rawString
}
