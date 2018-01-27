import Foundation

// swiftlint:disable function_parameter_count
public protocol RestFetcherBuilder {
    func createRestFetcher(resource: String,
                           method: RFMethod,
                           headers: [String: String],
                           body: String,
                           successCallback: @escaping (_ response: RFResponse) -> Void,
                           errorCallback: @escaping (_ error: NSError) -> Void) -> RFRestFetcher
}

@objc
open class RFRestFetcher: NSObject {
    
    public class Builder: RestFetcherBuilder {
        public func createRestFetcher(resource: String,
                                      method: RFMethod,
                                      headers: [String: String],
                                      body: String,
                                      successCallback: @escaping (_ response: RFResponse) -> Void,
                                      errorCallback: @escaping (_ error: NSError) -> Void) -> RFRestFetcher {
            return RFRestFetcher(resource: resource,
                               method: method,
                               headers: headers,
                               body: body,
                               successCallback: successCallback,
                               errorCallback: errorCallback)
        }
    }
    
    private var logger: RFConsoleLogger = RFConsoleLogger()
    private let timeout: TimeInterval = 30
    private let resource: String!
    private let method: RFMethod!
    private let headers: [String: String]
    private let body: String?
    private let successCallback: (_ response: RFResponse) -> Void
    private let errorCallback: (_ error: NSError) -> Void
    private var session: URLSession = URLSession.shared
    
    public init(resource: String,
                method: RFMethod,
                headers: [String: String],
                body: String,
                successCallback: @escaping (_ response: RFResponse) -> Void,
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
        var request = URLRequest(url: getUrl(), cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = method.rawValue
        
        request = addHeaders(request)
        
        request = addBody(request)
        
        if RFEnvironemnt().isLogging() {
            logRequest(request)
        }
        
        return request
    }
    
    func setUrlSession(session: URLSession) {
        self.session = session
    }
    
    func urlSessionComplete(data: Data?, response: URLResponse?, error: Error?) {
        guard let urlResponse = response as? HTTPURLResponse else {
            sendError(NSError(domain: "RestFetcher", code: 0, userInfo: ["message": "Network Error"]))
            return
        }
        
        if RFEnvironemnt().isLogging() {
            logResponse(urlResponse, data: data)
        }
        
        if let e = error {
            sendError(NSError(domain: "RestFetcher", code: e._code, userInfo: ["message": "Network Error"]))
        } else  if isSuccessCode(urlResponse.statusCode) {
            let restResponse = RFResponse(headers: extractHeaders(urlResponse: urlResponse),
                                            code: urlResponse.statusCode,
                                            data: data)
            sendSuccess(restResponse)
        } else {
            let headers = extractHeaders(urlResponse: urlResponse)
            let userInfo: [String: Any] = ["message": dataToString(data),
                                                "headers": headers]
            sendError(NSError(domain: "RestFetcher", code: urlResponse.statusCode, userInfo: userInfo))
        }
    }
    
    private func extractHeaders(urlResponse: HTTPURLResponse) -> [String: String] {
        if let headers = urlResponse.allHeaderFields as? [String: String] {
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
    
    private func sendSuccess(_ response: RFResponse) {
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
            updatedRequest.httpBody = str.data(using: .utf8)
        }
        return updatedRequest
    }
    
    private func logRequest(_ request: URLRequest) {
        logger.logRequest(callId: "\(hashValue) \(method.rawValue)", url: resource, headers: headers, body: body)
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        logger.logResponse(callId: "\(hashValue) \(method.rawValue)",
            url: resource,
            code: response.statusCode,
            headers: headers,
            body: dataToString(data))
    }
    
    private func dataToString(_ data: Data?) -> String {
        var output = ""
        if let d = data {
            if let str = String(data: d, encoding: .utf8) {
                output = str as String
            }
        }
        return output
    }
    
    private func isSuccessCode(_ code: Int) -> Bool {
        return code >= 200 && code <= 299
    }
    
}
