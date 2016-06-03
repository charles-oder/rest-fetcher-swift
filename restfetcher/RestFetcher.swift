import Foundation

public protocol RestFetcherBuilder {
    func createRestFetcher(resource: String, method: RestMethod, headers:Dictionary<String, String>, body:String, successCallback: (response:RestResponse)->(), errorCallback:(error:NSError)->()) -> RestFetcher;
}

@objc
public class RestFetcher: NSObject {
    
    public class Builder : RestFetcherBuilder {
        public func createRestFetcher(resource: String, method: RestMethod, headers:Dictionary<String, String>, body:String, successCallback: (response:RestResponse)->(), errorCallback:(error:NSError)->()) -> RestFetcher {
            return RestFetcher(resource: resource, method: method, headers: headers, body: body, successCallback: successCallback, errorCallback: errorCallback)
        }
    }
    
    private var logger: RestFetcherLogger? = ConsoleLogger()
    public func setLogger(logger: RestFetcherLogger?) {
        self.logger = logger
    }
    
    private let timeout: NSTimeInterval = 30
    private let resource: String!
    private let method: RestMethod!
    private let headers: Dictionary<String, String>!
    private let body: String?
    private let successCallback: (response: RestResponse) -> ()
    private let errorCallback: (error: NSError) -> ()
    private var session: NSURLSession = NSURLSession.sharedSession()
    private let mainThread: dispatch_queue_t = dispatch_get_main_queue();

    public init(resource: String, method: RestMethod, headers: Dictionary<String, String>, body: String, successCallback: (response: RestResponse) -> (), errorCallback: (error: NSError) -> ()) {
        self.resource = resource
        self.method = method
        self.headers = headers
        self.body = body
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
    
    public func fetch() {
        let task = session.dataTaskWithRequest(createRequest(), completionHandler: urlSessionComplete)
        task.resume()
    }
    
    public func createRequest() -> NSURLRequest {
        let request = NSMutableURLRequest(URL: getUrl(), cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval:timeout)
        
        request.HTTPMethod = method.getString()
        
        addHeaders(request)
        
        addBody(request)
        
        if RestFetcherEnvironemnt().isLogging() {
            logRequest(request)
        }
        
        return request
    }
    
    func setUrlSession(session: NSURLSession) {
        self.session = session
    }
    
    func urlSessionComplete(data:NSData?, response:NSURLResponse?, error:NSError?) {
        guard let urlResponse = response as? NSHTTPURLResponse else {
            sendError(NSError(domain: "RestFetcher", code: RestResponseCode.UNKNOWN.rawValue, userInfo: ["message":"Network Error"]))
            return
        }
        
        if RestFetcherEnvironemnt().isLogging() {
            logResponse(urlResponse, data: data)
        }
        
        if let e = error {
            sendError(NSError(domain: "RestFetcher", code: e.code, userInfo: ["message":"Network Error"]))
        } else  if isSuccessCode(urlResponse.statusCode) {
            sendSuccess(RestResponse(headers: extractHeaders(urlResponse), code: RestResponseCode.getResponseCode(urlResponse.statusCode), data: data))
        } else {
            sendError(NSError(domain: "RestFetcher", code: urlResponse.statusCode, userInfo: ["message":dataToString(data)]))
        }
    }
    
    private func extractHeaders(urlResponse: NSHTTPURLResponse) -> [String : String] {
        if let headers = urlResponse.allHeaderFields as? [String : String] {
            return headers
        } else {
            return Dictionary<String, String>()
        }
    }
    
    private func sendError(error: NSError) {
        dispatch_async(mainThread, {
            self.errorCallback(error: error)
        })
    }
    
    private func sendSuccess(response: RestResponse) {
        dispatch_async(mainThread, {
            self.successCallback(response: response)
        })
    }
    
    private func getUrl() -> NSURL {
        return NSURL(string: resource)!
    }
    
    private func addHeaders(request:NSMutableURLRequest) {
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func addBody(request:NSMutableURLRequest) {
        if let str = body {
            request.HTTPBody = str.dataUsingEncoding(NSUTF8StringEncoding)
        }
    }
    
    private func logRequest(request:NSMutableURLRequest) {
        logger?.logRequest("\(hashValue) \(method.getString())", url: resource, headers: headers, body: body)
    }
    
    private func logResponse(response: NSHTTPURLResponse, data: NSData?) {
        logger?.logResponse("\(hashValue) \(method.getString())", url: resource, code: response.statusCode, headers: headers, body: dataToString(data))
    }
    
    private func dataToString(data:NSData?) -> String {
        var output = ""
        if let d = data {
            if let str = NSString(data: d, encoding: NSUTF8StringEncoding) {
                output = str as String
            }
        }
        return output
    }
    
    private func isSuccessCode(code: Int) -> Bool {
        return code >= 200 && code <= 299
    }
    
}
