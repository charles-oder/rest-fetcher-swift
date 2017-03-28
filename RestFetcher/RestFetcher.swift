import Foundation

// swiftlint:disable function_parameter_count
public protocol RestFetcherBuilder {
    func createRestFetcher(resource: String,
                           method: RestMethod,
                           headers: [String: String],
                           body: String,
                           successCallback: @escaping (_ response: RestResponse) -> Void,
                           errorCallback: @escaping (_ error: NSError) -> Void) -> RestFetcher
}

@objc
open class RestFetcher: NSObject {
    
    public class Builder: RestFetcherBuilder {
        public func createRestFetcher(resource: String,
                                      method: RestMethod,
                                      headers: [String: String],
                                      body: String,
                                      successCallback: @escaping (_ response: RestResponse) -> Void,
                                      errorCallback: @escaping (_ error: NSError) -> Void) -> RestFetcher {
            return RestFetcher(resource: resource,
                               method: method,
                               headers: headers,
                               body: body,
                               successCallback: successCallback,
                               errorCallback: errorCallback)
        }
    }
    
    private var logger: ConsoleLogger = ConsoleLogger()
    private let timeout: TimeInterval = 30
    private let resource: String!
    private let method: RestMethod!
    private let headers: [String: String]
    private let body: String?
    private let successCallback: (_ response: RestResponse) -> Void
    private let errorCallback: (_ error: NSError) -> Void
    private var session: URLSession = URLSession.shared
    
    public init(resource: String,
                method: RestMethod,
                headers: [String: String],
                body: String,
                successCallback: @escaping (_ response: RestResponse) -> Void,
                errorCallback: @escaping (_ error: NSError) -> Void) {
        self.resource = resource
        self.method = method
        self.headers = headers
        self.body = body
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
    
    open func fetch() {
        let task = session.dataTask(with: createRequest(), completionHandler: urlSessionComplete)
        task.resume()
    }
    
    public func createRequest() -> URLRequest {
        var request = URLRequest(url: getUrl(), cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval:timeout)
        
        request.httpMethod = method.getString()
        
        request = addHeaders(request)
        
        request = addBody(request)
        
        if RestFetcherEnvironemnt().isLogging() {
            logRequest(request)
        }
        
        return request
    }
    
    func setUrlSession(session: URLSession) {
        self.session = session
    }
    
    func urlSessionComplete(data: Data?, response: URLResponse?, error: Error?) {
        guard let urlResponse = response as? HTTPURLResponse else {
            sendError(NSError(domain: "RestFetcher", code: RestResponseCode.unknown.rawValue, userInfo: ["message": "Network Error"]))
            return
        }
        
        if RestFetcherEnvironemnt().isLogging() {
            logResponse(urlResponse, data: data)
        }
        
        if let e = error {
            sendError(NSError(domain: "RestFetcher", code: e._code, userInfo: ["message": "Network Error"]))
        } else  if isSuccessCode(urlResponse.statusCode) {
            let restResponse = RestResponse(headers: extractHeaders(urlResponse: urlResponse),
                                            code: RestResponseCode.getResponseCode(urlResponse.statusCode),
                                            data: data)
            sendSuccess(restResponse)
        } else {
            sendError(NSError(domain: "RestFetcher", code: urlResponse.statusCode, userInfo: ["message": dataToString(data)]))
        }
    }
    
    private func extractHeaders(urlResponse: HTTPURLResponse) -> [String : String] {
        if let headers = urlResponse.allHeaderFields as? [String : String] {
            return headers
        } else {
            return [:]
        }
    }
    
    private func sendError(_ error: NSError) {
        DispatchQueue.main.async {
            self.errorCallback(error)
        }
    }
    
    private func sendSuccess(_ response: RestResponse) {
        DispatchQueue.main.async {
            self.successCallback(response)
        }
    }
    
    private func getUrl() -> URL {
        return URL(string: resource) ?? URL(fileURLWithPath: "")
    }
    
    private func addHeaders(_ request: URLRequest) -> URLRequest {
        var updatedRequest = request
        for (key, value) in headers {
            updatedRequest.addValue(value, forHTTPHeaderField: key)
        }
        return updatedRequest
    }
    
    private func addBody(_ request: URLRequest) -> URLRequest {
        var updatedRequest = request
        if let str = body {
            updatedRequest.httpBody = str.data(using: String.Encoding.utf8)
        }
        return updatedRequest
    }
    
    private func logRequest(_ request: URLRequest) {
        logger.logRequest(callId: "\(hashValue) \(method.getString())", url: resource, headers: headers, body: body)
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        logger.logResponse(callId: "\(hashValue) \(method.getString())",
            url: resource,
            code: response.statusCode,
            headers: headers,
            body: dataToString(data))
    }
    
    private func dataToString(_ data: Data?) -> String {
        var output = ""
        if let d = data {
            if let str = NSString(data: d, encoding: String.Encoding.utf8.rawValue) {
                output = str as String
            }
        }
        return output
    }
    
    private func isSuccessCode(_ code: Int) -> Bool {
        return code >= 200 && code <= 299
    }
    
}
