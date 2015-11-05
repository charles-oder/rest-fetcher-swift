import Foundation

public protocol RestFetcherBuilder {
    func createRestFetcher(resource: String, method: RestMethod, headers:Dictionary<String, String>, body:String, successCallback: (response:RestResponse)->(), errorCallback:(error:RestError)->()) -> RestFetcher;
}

public class RestFetcher {
    
    public class Builder : RestFetcherBuilder {
        public func createRestFetcher(resource: String, method: RestMethod, headers:Dictionary<String, String>, body:String, successCallback: (response:RestResponse)->(), errorCallback:(error:RestError)->()) -> RestFetcher {
            return RestFetcher(resource: resource, method: method, headers: headers, body: body, successCallback: successCallback, errorCallback: errorCallback)
        }
    }

    private let timeout: NSTimeInterval = 30
    private let resource: String!
    private let method: RestMethod!
    private let headers: Dictionary<String, String>!
    private let body: String?
    private let successCallback: (response: RestResponse) -> ()
    private let errorCallback: (error: RestError) -> ()
    private var session: NSURLSession = NSURLSession.sharedSession()

    public init(resource: String, method: RestMethod, headers: Dictionary<String, String>, body: String, successCallback: (response: RestResponse) -> (), errorCallback: (error: RestError) -> ()) {
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
        
        request.HTTPMethod = method.rawValue
        
        addHeaders(request)
        
        addBody(request)
        
        logRequest(request)
        
        return request
    }
    
    func setUrlSession(session: NSURLSession) {
        self.session = session
    }
    
    func urlSessionComplete(data:NSData?, response:NSURLResponse?, error:NSError?) {
        guard let urlResponse = response as? NSHTTPURLResponse else {
            errorCallback(error: RestError(code: RestResponseCode.UNKNOWN.rawValue, reason: "Network Error"))
            return
        }
        
        logResponse(urlResponse, data: data)
        
        if let e = error {
            errorCallback(error: RestError(code: e.code, reason: "Network Error"))
        } else  if isSuccessCode(urlResponse.statusCode) {
            successCallback(response: RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.getResponseCode(urlResponse.statusCode), body: dataToString(data)))
        } else {
            errorCallback(error: RestError(code: urlResponse.statusCode, reason: dataToString(data)))
        }
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
        print("making \(method.rawValue) call...")
        print("URL: \(resource)")
        print("Headers:")
        for (key, val) in headers {
            print("\(key): \(val)")
        }
        print("Body: \(body)")

    }
    
    private func logResponse(response: NSHTTPURLResponse, data: NSData?) {
        print("\(method.rawValue) response received: \(response.statusCode)")
        print("Headers:")
        for (key, val) in response.allHeaderFields {
            print("\(key): \(val)")
        }
        print("Body: \(dataToString(data))")
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
