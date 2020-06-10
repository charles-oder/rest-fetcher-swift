import Foundation

open class RFRequest<T: RFDecodable> {
    
    private var _cancel = false
    private var _restFetcher: RFRestFetcher?

    public enum ErrorCode: Int {
        case createResponseError = 10_001
    }
    
    var requestId: String = UUID().uuidString
    
    public var restFetcherBuilder: RestFetcherBuilder
    
    public var successCallback : (_ code: Int, _ response: T.ResponseType?) -> Void = { _, _ in }
    public var errorCallback : (_ error: NSError) -> Void = { _ in }
    
    public init(restFetcherBuilder: RestFetcherBuilder = RFRestFetcher.defaultBuilder) {
        self.restFetcherBuilder = restFetcherBuilder
    }
    
    open var logger: RFLogger {
        return RFConsoleLogger()
    }
    
    open var timeout: TimeInterval {
        return 30
    }
    
    open var keysToScrub: [String] {
        return ["password"]
    }
    
    open var restMethod: RFMethod {
        return RFMethod.get
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
            output += "\(key)=\(value.encodedQueryArgument ?? "")"
            firstArg = false
        }
        return output
    }
    
    open var requestBodyData: Data? {
        return requestBodyString?.data(using: .utf8)
    }
    
    open var requestBodyString: String? {
        var bodyData: Data
        let bodyDict = requestBodyDictionary
        if bodyDict.isEmpty {
            return nil
        }

        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch _ {
            bodyData = Data()
        }

        if let output = String(data: bodyData, encoding: .utf8) {
            return output
        }
        return nil // will never be hit in this code
    }
    
    open var requestBodyDictionary: [String: Any?] {
        return [:]
    }
    
    open var requestHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Accept"] = T.acceptType
        return headers
    }
    
    open func willFetchRequest(resource: String, method: RFMethod, headers: [String: String], bodyString: String?) {
        logRequest(resource: resource, method: method, headers: headers, bodyString: bodyString)
    }

    open func willCreateResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) {
        logResponse(responseTime: responseTime, code: code, headers: headers, data: data)
    }
    
    open func createResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) throws -> T.ResponseType? {
        return try T(data: data)?.object
    }

    func restFetcherSuccess(response: RFResponse) {
        if !_cancel {
            willCreateResponse(responseTime: response.responseTime, code: response.code, headers: response.headers, data: response.data)
            do {
                let apiResponse = try createResponse(responseTime: response.responseTime,
                                                     code: response.code,
                                                     headers: response.headers,
                                                     data: response.data)
                onSuccess(response.code, apiResponse)
            } catch {
                let nsError = NSError(domain: "createResponse",
                                      code: ErrorCode.createResponseError.rawValue,
                                      userInfo: ["error": error])
                errorCallback(nsError)
            }

        }
    }
    
    func restFetcherError(error: NSError) {
        if !_cancel {
            logError(error)
            onError(error)
        }
    }
    
    open func onSuccess(_ code: Int, _ response: T.ResponseType?) {
        successCallback(code, response)
    }
    
    open func onError(_ error: NSError) {
        errorCallback(error)
    }
    
    open func prepare() {
        _restFetcher = restFetcherBuilder.createRestFetcher(resource: requestUrlString,
                                                            method: restMethod,
                                                            headers: requestHeaders,
                                                            body: requestBodyData,
                                                            logger: logger,
                                                            timeout: timeout,
                                                            successCallback: restFetcherSuccess,
                                                            errorCallback: restFetcherError)
    }
    
    open func fetch() {
        if let fetcher = _restFetcher {
            willFetchRequest(resource: requestUrlString, method: restMethod, headers: requestHeaders, bodyString: requestBodyString)
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

fileprivate extension String {
    var encodedQueryArgument: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "&", with: "%26")
    }
}
