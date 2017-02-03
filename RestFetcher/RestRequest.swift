import Foundation


open class RestRequest<T> {
    
    private var _cancel = false
    private var _restFetcher : RestFetcher?
    public var restFetcherBuilder : RestFetcherBuilder
    
    public var successCallback : (_ code: RestResponseCode, _ response:T?)->() = { _ in }
    public var errorCallback : (_ error:NSError)->() = { _ in }
    
    public init() {
        self.restFetcherBuilder = RestFetcher.Builder()
    }
    
    public func setRestFetcherBuilder(restFetcherBuilder: RestFetcherBuilder) {
        self.restFetcherBuilder = restFetcherBuilder
    }
    
    open var restMethod: RestMethod {
        return RestMethod.get
    }
    
    open var domain: String {
        return "https://google.com"
    }
    
    open var rootPath: String {
        return ""
    }
    
    open var pathResource: String {
        return ""
    }
    
    open var queryArguments: Dictionary<String, String> {
        return Dictionary<String, String>()
    }
    
    public var urlPath: String {
        return "\(domain)\(rootPath)\(pathResource)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    public var requestUrlString: String {
        return "\(urlPath)\(queryString)"
    }
    
    open var queryString: String {
        var firstArg = true
        var output = ""
        for (key, value) in queryArguments {
            output += firstArg ? "?" : "&"
            output += "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            firstArg = false
        }
        return output
    }
    
    open var requestBody: String {
        let bodyDict = requestBodyDictionary
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
    
    open var requestBodyDictionary: Dictionary<String, Any?> {
        return Dictionary<String, Any?>()
    }
    
    
    open var requestHeaders: Dictionary<String, String> {
        return Dictionary<String,String>()
    }
    
    open func createResponse(code: Int, headers: Dictionary<String, String>, data: Data?, body: String?) -> T? {
        return nil
    }
    
    func restFetcherSuccess(response:RestResponse) {
        if !_cancel {
            let apiResponse = createResponse(code: response.code.rawValue, headers: response.headers, data: response.data, body: response.body)
            onSuccess(response.code, apiResponse)
        }
    }
    
    func restFetcherError(error:NSError) {
        if !_cancel {
            onError(error)
        }
    }
    
    open func onSuccess(_ code: RestResponseCode, _ response:T?) {
        successCallback(code, response)
    }
    
    open func onError(_ error:NSError) {
        errorCallback(error)
    }
    
    open func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(resource: requestUrlString, method: restMethod, headers: requestHeaders, body: requestBody, successCallback: restFetcherSuccess, errorCallback: restFetcherError)
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
