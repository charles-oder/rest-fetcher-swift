import Foundation


open class RestApiBaseRequest<T: RestApiBaseResponse> {
    
    private var _cancel = false
    private var _restFetcher : RestFetcher?
    public var restFetcherBuilder : RestFetcherBuilder
    
    var successCallback : (_ response:T)->() = {(response: RestApiBaseResponse)->()in}
    var errorCallback : (_ error:NSError)->() = {(error:NSError)->()in}
    
    public init(successCallback: @escaping (_ response:T)->(), errorCallback: @escaping (_ error:NSError)->()) {
        self.successCallback = successCallback
        self.errorCallback = errorCallback
        self.restFetcherBuilder = RestFetcher.Builder()
    }
    
    public func setRestFetcherBuilder(restFetcherBuilder: RestFetcherBuilder) {
        self.restFetcherBuilder = restFetcherBuilder
    }
    
    open func getRestMethod() -> RestMethod {
        return RestMethod.GET
    }
    
    open func getApiBase() -> String {
        return "http://google.com"
    }
    
    open func getApiRoot() -> String {
        return ""
    }
    
    open func getQueryArguments() -> Dictionary<String, String> {
        return Dictionary<String, String>()
    }
    
    open func getQueryString() -> String {
        var firstArg = true
        var output = ""
        for (key, value) in getQueryArguments() {
            output += firstArg ? "?" : "&"
            output += "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
            firstArg = false
        }
        return output
    }
    
    open func getApiResource() -> String {
        return "\(getApiBase())\(getApiRoot())"
    }
    
    open func getBody() -> String {
        let bodyDict = getBodyDict()
        if bodyDict.count == 0 {
            return ""
        }
        var bodyData: Data
        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch _ {
            bodyData = Data()
        }
        
        if let output = NSString(data: bodyData, encoding: String.Encoding.utf8.rawValue) as? String {
            return output
        }
        return "" // will never be hit in this code
    }
    
    open func getBodyDict() -> Dictionary<String, Any?> {
        return Dictionary<String, Any?>()
    }
    
    
    open func getHeaders() -> Dictionary<String, String> {
        return Dictionary<String,String>()
    }
    
    open func createResponse(_ response:RestResponse) -> T {
        return RestApiBaseResponse(response: response) as! T
    }
    
    func restFetcherSuccess(response:RestResponse) {
        if !_cancel {
            let apiResponse = createResponse(response)
            apiResponse.request = self
            onSuccess(apiResponse)
        }
    }
    
    func restFetcherError(error:NSError) {
        if !_cancel {
            onError(error)
        }
    }
    
    open func onSuccess(_ response:T) {
        successCallback(response)
    }
    
    open func onError(_ error:NSError) {
        errorCallback(error)
    }
    
    func buildUrlString() -> String {
        return "\(getApiResource())\(getQueryString())"
    }
    
    open func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(resource: buildUrlString(), method: getRestMethod(), headers: getHeaders(), body: getBody(), successCallback: restFetcherSuccess, errorCallback: restFetcherError)
    }
    
    open func fetch() {
        if let fetcher = _restFetcher {
            fetcher.fetch()
        } else {
            prepare()
            fetch()
        }
    }
    
    open func cancel() {
        _cancel = true
    }
}

open class RestApiBaseResponse {
    
    private var _code : RestResponseCode = RestResponseCode.UNKNOWN
    public let response : RestResponse!
    internal(set) public var request: Any!
    var code: RestResponseCode {
        get {
            return _code
        }
    }
    
    public init(response:RestResponse) {
        self.response = response
        processResponse(response)
    }
    
    open func processResponse(_ response:RestResponse) {
        _code = response.code
    }
}
