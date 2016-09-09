import Foundation


public class RestApiBaseRequest<T: RestApiBaseResponse> {
    
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
            output += "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
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

    public func getBodyDict() -> Dictionary<String, AnyObject> {
        return Dictionary<String, AnyObject>()
    }

    
    public func getHeaders() -> Dictionary<String, String> {
        return Dictionary<String,String>()
    }

    public func createResponse(_ response:RestResponse) -> T {
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
    
    public func onSuccess(_ response:T) {
        successCallback(response)
    }
    
    public func onError(_ error:NSError) {
        errorCallback(error)
    }
    
    func buildUrlString() -> String {
        return "\(getApiResource())\(getQueryString())"
    }
    
    public func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(resource: buildUrlString(), method: getRestMethod(), headers: getHeaders(), body: getBody(), successCallback: restFetcherSuccess, errorCallback: restFetcherError)
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
    
    public func processResponse(_ response:RestResponse) {
        _code = response.code
    }
}
