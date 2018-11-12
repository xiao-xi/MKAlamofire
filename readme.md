# Monkey 网络设计

## source（文件夹）

### MKConfig 
网络配置

```
shareInstance
```

#### protocol

```
MKURLFilterProtocol     //遵守此协议并实现其方法重写requestUrl地址
MKCacheDirPathFilterProtocol    //遵守此协议并实现其方法重写缓存位置（未使用）
```

#### class

```
MKConfig    //设置网络相关配置
```

#### 使用

```
//AppDelegate.swift
MKConfig.shared.baseURL = Environment.baseURL
MKConfig.shared.acceptType = ["application/vnd.api+json", "application/json"]
MKConfig.shared.debugLogEnable = true
MKConfig.shared.allowsCellularAccess = true
MKConfig.shared.cdnURL = ""
...
```

### MKAgent / shareInstance
对`Alamofire`的封装使用，开发者不需要关注此类，除非封装出现bug需要重构

#### wait : func 
*需要注意的地方*
下面的方法提供了一个网络请求`wait`操作
可以等待某个网络请求，等此请求结束后再进行之后的请求
```
/// 等待本次网络请求结束，才能继续之后的网络请求
/// 一个`wait`必须对应一个`resum`或者`cancel`
/// - Parameters:
///   - request: 本次网络请求
///   - tag: 本次网络请求的tag：必传且 > 0
public func wait(for request:MKBaseRequest, Tag tag:Int)

/// 本次请求结束之后调用，继续请求被拦截下来的请求对象
public func resumWaitRequests()

/* 本次请求结束之后调用，
 被缓存的请求对象数组依赖本次请求
 若本次请求失败可以调用此方法释放所有被拦截的请求对象
 */
public func cancelAllWaitRequest()

```

### MKBaseRequestProcotol / protocol
一系列的网络相关枚举类型及协
开发者不需要关注此类，除非封装出现bug需要重构或者需要在此处重新定义行为

#### enum

```
MKRequestPriority
MKResponseType
MKHTTPMethod
MKParameterEncoding
```

#### protocol

```
MKRequestProtocol
MKRequestAccessoryProtocol
BaseRequest
```
### MKBaseRequest : BaseRequest
遵循`BaseRequest`协议
初始化`BaseRequest`协议中的参数并赋予默认值
声明`request properties`相关信息
初始化`response properties`相关信息
在这里使用`MKAgent`进行网络请求，并获取返回数据
开发者需要熟悉此类的需要重写的参数及方法，以便后续的使用及扩展

**开发时若无自定义输入及输出数据的特殊处理，应该针对每个网络接口请求创建继承自`MKBaseRequest`的子类，并重写各项配置参数，即可进行网络请求获取返回数据**
```
//resquest
open var baseURL: String { return "" }
    
open var requestURL: String { return "" }
    
open var cdnURL: String { return "" }
    
open var requestMethod: MKHTTPMethod { return .get }
    
open var requestHeaders: WBHTTPHeaders? { return nil }
    
open var requestParams: [String: Any]? { return nil }
    
open var paramEncoding: MKParameterEncoding { return .url }
    
open var responseType: MKResponseType { return .json }
    
open var priority: MKRequestPriority? { return nil }
    
open var requestDataClosure: BaseRequest.MKMutableDataClosure? { return nil }
    
open var uploadFile: URL? { return nil }

open var uploadData: Data? { return nil }
    
open var resumableDownloadPath: String { return "" }
    
open var requestAuthHeaders: [String]? { return nil }

open var useCDN: Bool { return false }

//response
///请求状态码
open  var statusCode: Int { return request?.response?.statusCode ?? 500 }
    
/// 请求状态
///  Return cancelled state of request task.
open var state : URLSessionTask.State? { return request?.task?.state }
    
/// 请求获取的数据
///  The raw data representation of response. Note this value may be nil if request failed.
open var responseData: Data?
    
/// 请求获取的string(返回类型为Data和String<objc返回为data时也生效>生效)
///  The string representation of response. Note this value may be nil if request failed.
open var responseString: String?
    
/// 默认返回的数据结果
///  This serialized response object. The actual type of this object is determined by
///  `MKResponseType.default` or `MKResponseType.data`. Note this value
///  can be nil if request failed.
///
///  @discussion If `resumableDownloadPath` and DownloadTask is using, this value will
///  be the path to which file is successfully saved (NSURL), or nil if request failed.
open var responseObj: Any?
    
/// 返回为json时请求的结果
///  If you use `MKResponseType.json`, this is a convenience (and sematic) getter
///  for the response Json. Otherwise this value is nil.
open var responseJson: [String: Any]?
    
/// 返回为plist时请求的结果
///  If you use `MKResponseType.plist`, this is a convenience (and sematic) getter
///  for the response Plist. Otherwise this value is nil.
open var responsePlist: Any?
    
/// 这是下载专用的url，仅当有下载时才生效. Default nil.
/// If you use `resumableDownloadPath`, this is a convenience (and sematic) getter
///  for the response result. Otherwise this value is nil.
open var downloadURL: URL?
    
/// 请求失败error
///  This error can be either serialization error or network error. If nothing wrong happens
///  this value will be nil.
open var error: Error?
    
///  The current request.
open var request: Request?
```

### ChainRequest final
链式请求
提供有序的网络请求，如A请求结束之后B开始请求，B请求结束之后C开始请求
提供统每个接口单独的回调
提供代理方法
当遇到某个接口请求失败时会停止请求

```
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
```

### BatchRequest final
批量请求，例如[A, B, C]请求同时异步进行
提供统一的回调
提供代理方法
提供单独接口的回调
当所有请求结束之后回调
可以通过参数`failedRequests`查看失败的`request`
```
func startBatchRequest() {
    let accountBatchApi = accountKitApi()
    let registerBatchApi = RegisterApi.init("sss", "sss")
    let loginBatchApi = LoginApi.init("sss", "sss")
    
    let batchRequest = MKBatchRequest(MKRequests: [accountBatchApi, registerBatchApi, loginBatchApi])
    batchRequest.start({ (batch) in
        print("batch success")
    }) { (batch) in
        print("batch failed")
    }
}
```

### MKUtils / class（文件夹）
对工具方法的封装，开发者不需要关注此类，除非封装出现bug需要重构

### MKCacheRequest: MKBaseRequest （文件夹）
以`MKBaseRequest`为父类，增加了缓存网络返回数据的功能

```
open class MKCacheRequest : MKBaseRequest{

    open var ignoreCache: Bool = false
    
    open var isDataFromCache: Bool { return _dataFromCache }
    
    // MARK: - SubClass Override
    
    /// 多长时间范围内不进行网络请求，使用缓存作为请求的返回数据.默认2m
    ///  The max time duration that cache can stay in disk until it's considered expired.
    ///  Default is 2m, which means response will actually saved as cache.
    open var cacheInSeconds: TimeInterval { return 2 * 60 }
    
    /// 以版本号来缓存数据
    ///  Version can be used to identify and invalidate local cache. Default is 0.
    open var cacheVersion: Int { return 0 }
    
    /// sensitive data (可以根据两次不同的数据自动更新缓存)
    ///  This can be used as additional identifier that tells the cache needs updating.
    ///
    ///  @discussion The `description` string of this object will be used as an identifier to verify whether cache
    ///   is invalid. Using `NSArray` or `NSDictionary` as return value type is recommended. However,
    ///   If you intend to use your custom class type, make sure that `description` is correctly implemented.
    open var cacheSensitiveData: Data? { return nil }
    
    /// 是否自动异步缓存数据, Default true.
    ///  Whether cache is asynchronously written to storage. Default is YES.
    open var writeCacheAsynchronously: Bool { return true }
}
```


## Monkey Base （文件夹）

### MKApiRequest : MKBaseRequest
开发使用的基类
**开发人员应该新建继承自本类的子类，重写各项配置参数，使用指定初始化方法，使用指定请求方法可以便捷的获取经过处理的数据**

#### properties
设置所有请求公有的配置
```
//method
override var requestMethod: MKHTTPMethod{
    return MKHTTPMethod.get
}
//paramEncoding
override var paramEncoding: MKParameterEncoding{
    return MKParameterEncoding.url
}

//httpheader,
override var requestHeaders: WBHTTPHeaders?{
    //判断是否有Authorization
    return [
        "lang": "en-CN",
        "Version":"5.0",
        "Client":"cool.monkey.ios",
        "Device":"iOS",
        "Accept":"application/vnd.api+json, application/json",
        "Content-Type":"application/vnd.api+json",
        "User-Agent":"Sandbox/5.0 (cool.monkey.ios; build:73; iOS 11.4.1) Alamofire/4.7.3"
    ]
}
...
```

#### params 自定义入参

#####  realm

```
// 设置接口是否需要realm存储数据，默认为false
override var realm: Bool{
    return true
}
```

##### netParams

```
//网络请求参数，json类型 使用netParams的话不要重写`requestParams`方法
var netParams: [String: Any]?
```

##### dataKey

```
//response数据存放的key，默认为data字段中的数据
//有的返回数据不在此字段中，可以重写后返回nil
//可传入形如"data.user.friends"的路径使用更深层级的数据
//注意此路径里的内容必须为字典内容[String: Any]
var dataKey: String?{
    return "data"
}
```

##### Tip
在子类中可以增加更多的自定义入参，可以灵活使用

#### startRequest: func

##### startWithJSONResponse

```
//进行会返回模型对象的网络请求
public func startWithJSONResponse<T: MonkeyModel>(_ responseType:T.Type, success successHandler:@escaping successJSONCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void
```

##### startWithJSONArrayResponse

```
//进行会返回模型对象数组的网络请求
public func startWithJSONArrayResponse<T: MonkeyModel>(_ responseType:T.Type, success successHandler:@escaping successArrayCompletionHandler<T>, failed failedHandler: @escaping failedCompletionHandler) -> Void
```

#### reaponse 

* 回调中提供了
* `request`:请求对象本身 ,
* `responseModel` / `[responseModel]`: response转化的数据模型 / 数据模型数组,
* `errorModel`: `MKErrorModel`, `statusCode != 200` 时，服务器返回的错误信息或网络错误信息

##### request / api

通过`request`可以通过`get`方法获取所有的`request`属性及自定义参数等，这个`request`是发起请求的子类本身

##### responseModel / [responseModel]
根据`request.responseJson`和`dataKey`查找到相应的数据并根据需求转化成为模型或者模型数组

**方法回调的数据是根据参数`realm`决定是否存入realm数据库并从realm数据库中取出**

##### errorModel
请求失败时回调的错误信息，属性可能会只有`error_message`

#### 使用

##### api
```
class MKMeApi: MKApiRequest {
    override var realm: Bool{
        return false
    }
    
    override var requestURL: String{
        return "api/v2/me"
    }
    
    override var dataKey: String?{
        return nil
    }
    
    override var requestMethod: MKHTTPMethod{
        return MKHTTPMethod.post
    }
    
    override var paramEncoding: MKParameterEncoding{
        return MKParameterEncoding.json
    }
}
```

##### startRequest

```
let meInfoApi = MKMeApi()
meInfoApi.netParams = parameter
meInfoApi.startWithJSONResponse(RealmUser.self, success: { (api, model) in
    //
    guard let realm = try? Realm() else {
        return
    }
    
    guard let user = UserManager.shared.currentUser else {
        return
    }
    
    guard let remainTimes = api.responseJson?["contact_invite_remain_times"] as? Int, let unlock2p = api.responseJson?["unlocked_two_p"] as? Bool else {
        return
    }
    
    try! realm.write {
        user.cached_unlocked_two_p = unlock2p
        user.cached_contact_invite_remain_times = remainTimes
    }
    
    self.dispatch(selector: #selector(UserObserver.currentUserInfomationChanged))
}) { (api, errModel) in
    //
    print("request failed")
}
```

### MonkeyModel 
继承`Object`遵循`Mapable`协议，为所有的数据模型的基类,这里只展示部分信息
```
typealias MonkeyRealmObject = Object & RealmObjectProtocol
typealias MonkeyApiObject = CommonAPIRequestProtocol & SpecificAPIRequestProtocol
typealias MonkeyObject = MonkeyApiObject

class MonkeyModel: Object, Mappable, MonkeyObject {
	
	required convenience init?(map: Map) {
		self.init()
	}
	
	func mapping(map: Map) {
		
	}
	override func setValue(_ value: Any?, forKey key: String) {
		guard let property = type(of: self).sharedSchema()?.properties.first(where: { $0.name == key }) else {
			return super.setValue(value, forKey: key)
		}
		guard property.type == .date, let stringValue = value as? String else {
			return super.setValue(value, forKey: key)
		}
		super.setValue(RealmDataController.shared.parseDate(stringValue), forKey: key)
	}
}
```

### MKErrorModel: NSObject
服务器返回错误信息模型

```
//Status
enum MKErrorStatus : String{
    case Status_FORBIDDEN = "FORBIDDEN"
}

//ErrorCode
enum MKErrorCode : Int {
    case ErrorCode1 = 101101
    case MKErrorCodeRefreshToken = 101102
}

//ErrorType
enum MKErrorType : String {
    case ErrorType_AuthException = "AuthException"
}

class MKErrorModel: NSObject {
    //时间戳
    var timestamp: String?
    
    //错误信息
    var error_message: String?
    
    //错误状态
    var status: String?
    
    //错误码
    var error_code: MKErrorCode?
    
    //错误类型
    var error_type: MKErrorType?
    
    //response.error Error
    var error: Error?
    
    required convenience init(_ message:String?) {
        self.init()
        self.error_message = message
    }
}
```


