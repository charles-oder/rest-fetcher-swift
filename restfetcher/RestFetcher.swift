import Foundation

public class RestFetcher {

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
    
    func getUrl() -> NSURL {
        return NSURL(string: resource)!
    }
    
    
    public func createRequest() -> NSURLRequest {
        let request = NSMutableURLRequest(URL: getUrl(), cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval:timeout)
        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        if let str = body {
            request.HTTPBody = str.dataUsingEncoding(NSUTF8StringEncoding)
        }

        return request
    }
    
    func urlSessionComplete(data:NSData?, response:NSURLResponse?, error:NSError?) {
        guard let urlResponse = response as? NSHTTPURLResponse else {
            return
        }
        var body = ""
        if let d = data {
            if let str = NSString(data: d, encoding: NSUTF8StringEncoding) {
                body = str as String
            }
        }
        if let e = error {
            errorCallback(error: RestError(code: e.code, reason: "Network Error"))
        } else  if isSuccessCode(urlResponse.statusCode) {
            successCallback(response: RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.getResponseCode(urlResponse.statusCode), body: body))
        } else {
            errorCallback(error: RestError(code: urlResponse.statusCode, reason: body))
        }
    }
    
    private func isSuccessCode(code: Int) -> Bool {
        return code >= 200 && code <= 299
    }
}
