import Foundation

open class RestRequest<T> {
    
    private var _cancel = false
    private var _restFetcher: RestFetcher?
    public var restFetcherBuilder: RestFetcherBuilder
    
    public var successCallback : (_ code: RestResponseCode, _ response: T?) -> Void = { _, _ in }
    public var errorCallback : (_ error: NSError) -> Void = { _ in }
    
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
    
    open var queryArguments: [String: String] {
        return [:]
    }
    
    open var urlPath: String {
        let resource = "\(rootPath)\(pathResource)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return "\(domain)\(resource)"
    }
    
    open var requestUrlString: String {
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
        if bodyDict.isEmpty {
            return ""
        }
        var bodyData: Data
        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch _ {
            bodyData = Data()
        }
        
        if let output = String(data: bodyData, encoding: .utf8) {
            return output
        }
        return "" // will never be hit in this code
    }
    
    open var requestBodyDictionary: [String: Any?] {
        return [:]
    }
    
    open var requestHeaders: [String: String] {
        return [:]
    }
    
    open func willCreateResponse(code: Int, headers: [String: String], data: Data?) {
        // Logging hook
    }
    
    func restFetcherSuccess(response: RestResponse) {
        if !_cancel {
            willCreateResponse(code: response.code.rawValue, headers: response.headers, data: response.data)
            let apiResponse = createResponse(code: response.code.rawValue, headers: response.headers, data: response.data)
            onSuccess(response.code, apiResponse)
        }
    }
    
    func restFetcherError(error: NSError) {
        if !_cancel {
            onError(error)
        }
    }
    
    open func onSuccess(_ code: RestResponseCode, _ response: T?) {
        successCallback(code, response)
    }
    
    open func onError(_ error: NSError) {
        errorCallback(error)
    }
    
    open func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(resource: requestUrlString,
                                                            method: restMethod,
                                                            headers: requestHeaders,
                                                            body: requestBody,
                                                            successCallback: restFetcherSuccess,
                                                            errorCallback: restFetcherError)
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

public extension RestRequest where T: Decodable {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        guard let unwrappedData = data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: unwrappedData)
    }
}

public extension RestRequest where T == [Decodable] {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        guard let unwrappedData = data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: unwrappedData)
    }
}

public extension RestRequest where T == String {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        guard let unwrappedData = data else {
            return nil
        }
       return String(data: unwrappedData, encoding: .utf8)
    }
}

public extension RestRequest where T == Data {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        return data
    }
}

public extension RestRequest {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        return nil
    }
}
