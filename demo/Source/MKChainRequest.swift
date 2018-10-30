//
//  MKChainRequest.swift
//  MKAgent
//
//  Created by zwb on 17/3/30.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

///  MKChainRequest can be used to chain several MKBaseRequest so that one
///  will only starts after another finishes. Note that when used inside MKChainRequest,
///  a single MKBaseRequest will have its own callback and delegate cleared, in favor
///  of the batch request callback.
public final class MKChainRequest {

    public typealias MKChainRequestClosure = (_ chainRequest: MKChainRequest, _ baseRequest:MKBaseRequest) -> Void
  
// MARK: - Public Properties
    
///=============================================================================
/// @name Public Properties
///=============================================================================
    
    /// 所有的请求数组
    ///  All the requests are stored in this array.
    public private(set) var requests: [MKBaseRequest]
    
    /// 响应delegate
    ///  The delegate object of the chain request. Default is nil.
    public weak var delegate: MKChainRequestProtocol?
    
    /// 网络请求的协议组
    ///  This can be used to add several accossories object. Note if you use `add(_ requestAccessory:)` to add acceesory
    ///  this array will be automatically created. Default is nil.
    public private(set) var requestAccessories: [MKRequestAccessoryProtocol]?

// MARK: - Private Properties
    
///=============================================================================
/// @name Private Properties
///=============================================================================

    private let emptyCallBack: MKChainRequestClosure
    fileprivate var requestCallBacks: [MKChainRequestClosure]
    fileprivate var nextRequestIndex: Int
    public private(set) var rawString: String
    
// MARK: - Cycle Life
    
///=============================================================================
/// @name Cycle Life
///=============================================================================
    
    public init() {
        nextRequestIndex = 0
        requests = [MKBaseRequest]()
        requestCallBacks = [MKChainRequestClosure]()
        emptyCallBack = { _, _ in }
        rawString = UUID().uuidString
    }
    
// MARK: - Start Action
    
///=============================================================================
/// @name Start Action
///=============================================================================
    
    ///  Start the chain request, adding first request in the chain to request queue.
    public func start() {
        if nextRequestIndex > 0 {
            MKLog("Chain Error! Chain request has already started!")
            return
        }
        if !requests.isEmpty {
            self.totalAccessoriesWillStart()
            
            self.startNextRequest()
            MKChainAlamofire.shared.add(self)
        }else{
            MKLog("Chain Error! Chain requests is empty!")
        }
    }
    
    ///  Stop the chain request. Remaining request in chain will be cancelled.
    public func stop() {
        self.totalAccessoriesWillStop()
        self.delegate = nil
        self.cleanRequest()
        MKChainAlamofire.shared.remove(self)
        
        self.totalAccessoriesDidStop()
    }

    /// Add request to request chain.
    ///
    /// - Parameters:
    ///   - request: The request to be chained.
    ///   - closure: The finish callback
    public func add(_ request:MKBaseRequest, callBack closure: MKChainRequestClosure? = nil) {
        requests.append(request)
        if let closure = closure {
            requestCallBacks.append(closure)
        }else{
            requestCallBacks.append(emptyCallBack)
        }
    }
    
    ///  Convenience method to add request accessory. See also `requestAccessories`.
    public func add(_ requestAccessory: MKRequestAccessoryProtocol) {
        if requestAccessories == nil {
            requestAccessories = [MKRequestAccessoryProtocol]()
        }
        requestAccessories?.append(requestAccessory)
    }
    
// MARK: - Private
    
///=============================================================================
/// @name Private
///=============================================================================
    
    @discardableResult fileprivate func startNextRequest() -> Bool {
        if nextRequestIndex < requests.count {
            let request = requests[nextRequestIndex]
            nextRequestIndex += 1
            request.delegate = self
            request.clearCompleteClosure()
            request.start()
            return true
        }
        return false
    }
    
    private func cleanRequest() -> Void {
        let currentIndex = nextRequestIndex - 1
        if currentIndex <  requests.count {
            let request = requests[currentIndex]
            request.stop()
        }
        requests.removeAll()
        requestCallBacks.removeAll()
    }
}

// MARK: - MKRequestAccessoryProtocol

///=============================================================================
/// @name MKRequestAccessoryProtocol
///=============================================================================

extension MKChainRequest {
    
    func totalAccessoriesWillStart() -> Void {
        requestAccessories?.forEach {
            $0.requestWillStart(self)
        }
    }
    
    func totalAccessoriesWillStop() -> Void {
        requestAccessories?.forEach {
            $0.requestWillStop(self)
        }
    }
    
    func totalAccessoriesDidStop() -> Void {
        requestAccessories?.forEach {
            $0.requestDidStop(self)
        }
    }
}


// MARK: - Request Protocol

///=============================================================================
/// @name Request Protocol
///=============================================================================

extension MKChainRequest : MKRequestProtocol {
    
    public func requestFinish(_ request: MKBaseRequest) {
        let currentIndex = nextRequestIndex - 1
        let closure = requestCallBacks[currentIndex]
        closure(self, request)
        if !self.startNextRequest() {
            self.totalAccessoriesWillStop()
            
            if let delegate = delegate {
                delegate.chainRequestDidFinished(self)
                MKChainAlamofire.shared.remove(self)
            }
            self.totalAccessoriesDidStop()
        }
    }
    
    public func requestFailed(_ request: MKBaseRequest) {
        self.totalAccessoriesWillStop()
        if let delegate = delegate {
            delegate.chainRequestDidFailed(self, failedBaseRequest: request)
            MKChainAlamofire.shared.remove(self)
        }
        
        self.totalAccessoriesDidStop()
    }
}

// MARK: - MKChainRequestProtocol

///=============================================================================
/// @name MKChainRequestProtocol
///=============================================================================

///  The MKChainRequestProtocol protocol defines several optional methods you can use
///  to receive network-related messages. All the delegate methods will be called
///  on the main queue. Note the delegate methods will be called when all the requests
///  of chain request finishes.
public protocol MKChainRequestProtocol : class {
    
    /// Tell the delegate that the chain request has finished successfully.
    /// 链式响所有请求应成功的回调
    ///
    /// - Parameter chainRequest: The corresponding chain request.
    func chainRequestDidFinished(_ chainRequest: MKChainRequest) -> Void
    
    /// Tell the delegate that the chain request has failed.
    /// 响应失败触发回调
    ///
    /// - Parameters:
    ///   - chainRequest: The corresponding chain request.
    ///   - request: First failed request that causes the whole request to fail.
    func chainRequestDidFailed(_ chainRequest: MKChainRequest, failedBaseRequest request:MKBaseRequest) -> Void
}

extension MKChainRequestProtocol {
    public func chainRequestDidFinished(_ chainRequest: MKChainRequest) -> Void{}
    
    public func chainRequestDidFailed(_ chainRequest: MKChainRequest, failedBaseRequest request:MKBaseRequest) -> Void{}
}

// MARK: - MKChainAlamofire

///=============================================================================
/// @name MKChainAlamofire
///=============================================================================

///  MKChainAlamofire handles chain request management. It keeps track of all
///  the chain requests.
public final class MKChainAlamofire {
    
    ///  Get the shared chain request.
    public static let shared = MKChainAlamofire()
    
// MARK: - Private Properties
    
///=============================================================================
/// @name Private Properties
///=============================================================================
    
    private let _lock: NSLock
    private var _chainRequests: [MKChainRequest]
    
// MARK: - Cycle Life
    
///=============================================================================
/// @name Cycle Life
///=============================================================================
    
    public init() {
        _lock = NSLock()
        _chainRequests = [MKChainRequest]()
    }
    
// MARK: - Public
    
///=============================================================================
/// @name Public
///=============================================================================
    
    ///  Add a chain request.
    public func add(_ chainRequest: MKChainRequest) {
        _lock.lock()
        defer { _lock.unlock() }
        _chainRequests.append(chainRequest)
    }
    
    ///  Remove a previously added chain request.
    public func remove(_ chainRequest: MKChainRequest) {
        _lock.lock()
        defer { _lock.unlock() }
        let index = _chainRequests.index(where: { $0 == chainRequest })
        if let index = index {
            _chainRequests.remove(at: index)
        }
    }
}

extension MKChainRequest : Equatable {}

/// Overloaded operators
public func ==(
    lhs: MKChainRequest,
    rhs: MKChainRequest)
    -> Bool
{
    return lhs.rawString == rhs.rawString
}
