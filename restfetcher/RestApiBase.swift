import Foundation


public class RestApiBaseRequest<T: RestApiBaseResponse> {
    
    private var _cancel = false
    private var _restFetcher : RestFetcher?
    public var restFetcherBuilder : RestFetcherBuilder
    
    var successCallback : (response:T)->() = {(response: RestApiBaseResponse)->()in}
    var errorCallback : (error:NSError)->() = {(error:NSError)->()in}
    
    public init(successCallback:(response:T)->(), errorCallback:(error:NSError)->()) {
        self.successCallback = successCallback
        self.errorCallback = errorCallback
        self.restFetcherBuilder = RestFetcher.Builder()
    }

    public func setRestFetcherBuilder(restFetcherBuilder: RestFetcherBuilder) {
        self.restFetcherBuilder = restFetcherBuilder
    }

    public func getRestMethod() -> RestMethod {
        return RestMethod.GET
    }
    
    public func getApiBase() -> String {
        return "http://google.com"
    }
    
    public func getApiRoot() -> String {
        return ""
    }
    
    public func getQueryArguments() -> Dictionary<String, String> {
        return Dictionary<String, String>()
    }
    
    public func getQueryString() -> String {
        var firstArg = true
        var output = ""
        for (key, value) in getQueryArguments() {
            output += firstArg ? "?" : "&"
            output += "\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)"
            firstArg = false
        }
        return output
    }
        
    public func getApiResource() -> String {
        return "\(getApiBase())\(getApiRoot())"
    }
    
    public func getBody() -> String {
        let bodyDict = getBodyDict()
        if bodyDict.count == 0 {
            return ""
        }
        var bodyData: NSData
        do {
            bodyData = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: NSJSONWritingOptions(rawValue: 0))
        } catch _ {
            bodyData = NSData()
        }
        
        if let output = NSString(data: bodyData, encoding: NSUTF8StringEncoding) as? String {
            return output
        }
        return "" // will never be hit in this code
    }

    public func getBodyDict() -> Dictionary<String, AnyObject> {
        return Dictionary<String, AnyObject>()
    }

    
    public func getHeaders() -> Dictionary<String, String> {
        return Dictionary<String,String>()
    }

    public func createResponse(response:RestResponse) -> T {
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
    
    public func onSuccess(response:T) {
        successCallback(response: response)
    }
    
    public func onError(error:NSError) {
        errorCallback(error: error)
    }
    
    func buildUrlString() -> String {
        return "\(getApiResource())\(getQueryString())"
    }
    
    public func getLogger() -> RestFetcherLogger {
        return ConsoleLogger()
    }
    
    public func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(buildUrlString(), method: getRestMethod(), headers: getHeaders(), body: getBody(), successCallback: restFetcherSuccess, errorCallback: restFetcherError)
        _restFetcher?.setLogger(getLogger())
    }
    
    public func fetch() {
        if let fetcher = _restFetcher {
            fetcher.fetch()
        } else {
            prepare()
            fetch()
        }
    }
    
    public func cancel() {
        _cancel = true
    }
}
    
public class RestApiBaseResponse {
    
    private var _code : RestResponseCode = RestResponseCode.UNKNOWN
    public let response : RestResponse!
    internal(set) public var request: AnyObject!
    var code: RestResponseCode {
        get {
            return _code
        }
    }
    
    public init(response:RestResponse) {
        self.response = response
        processResponse(response)
    }
    
    public func processResponse(response:RestResponse) {
        _code = response.code
    }
}
