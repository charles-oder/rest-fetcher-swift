import Foundation

// swiftlint:disable function_parameter_count
public protocol RestFetcherBuilder {
    func createRestFetcher(resource: String,
                           method: RFMethod,
                           headers: [String: String],
                           body: Data?,
                           logger: RFLogger,
                           timeout: TimeInterval,
                           successCallback: @escaping (_ response: RFResponse) -> Void,
                           errorCallback: @escaping (_ error: NSError) -> Void) -> RFRestFetcher
}

@objc
open class RFRestFetcher: NSObject {
    
    public static var defaultBuilder = RFRestFetcher.Builder()
    
    public class Builder: RestFetcherBuilder {
        public func createRestFetcher(resource: String,
                                      method: RFMethod,
                                      headers: [String: String],
                                      body: Data?,
                                      logger: RFLogger,
                                      timeout: TimeInterval,
                                      successCallback: @escaping (_ response: RFResponse) -> Void,
                                      errorCallback: @escaping (_ error: NSError) -> Void) -> RFRestFetcher {
            return RFRestFetcher(resource: resource,
                                 method: method,
                                 headers: headers,
                                 body: body,
                                 logger: logger,
                                 timeout: timeout,
                                 successCallback: successCallback,
                                 errorCallback: errorCallback)
        }
    }
    
    private let logger: RFLogger
    private let timeout: TimeInterval
    private let resource: String!
    private let method: RFMethod!
    private let headers: [String: String]
    private let body: Data?
    private let successCallback: (_ response: RFResponse) -> Void
    private let errorCallback: (_ error: NSError) -> Void
    private var session: URLSession!
    
    private var startTime: UInt64 = 0
    
    public init(resource: String,
                method: RFMethod,
                headers: [String: String],
                body: Data?,
                logger: RFLogger,
                timeout: TimeInterval,
                successCallback: @escaping (_ response: RFResponse) -> Void,
                errorCallback: @escaping (_ error: NSError) -> Void) {
        self.resource = resource
        self.method = method
        self.headers = headers
        self.body = body
        self.logger = logger
        self.timeout = timeout
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
    
    open func fetch() {
        let task = getUrlSession().dataTask(with: createRequest(), completionHandler: urlSessionComplete)
        startTime = DispatchTime.now().uptimeNanoseconds
        task.resume()
    }
    
    public func createRequest() -> URLRequest {
        var request = URLRequest(url: getUrl(), cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = method.rawValue
        
        request = addHeaders(request)
        
        request = addBody(request)
        
        if RFEnvironment().isLogging() {
            logRequest(request)
        }
        
        return request
    }
    
    func setUrlSession(session: URLSession) {
        self.session = session
    }
    
    func getUrlSession() -> URLSession {
        if session == nil {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = timeout
            sessionConfig.timeoutIntervalForResource = timeout
            session = URLSession(configuration: sessionConfig)
        }
        return session
    }
    
    func urlSessionComplete(data: Data?, response: URLResponse?, error: Error?) {
        
        let responseTime = calculateResponseTimeInSeconds()
        guard let urlResponse = response as? HTTPURLResponse else {
            sendError(NSError(domain: "RestFetcher", code: 0, userInfo: ["time": "\(responseTime)",
                "message": "Network Error"]))
            return
        }
        
        if RFEnvironment().isLogging() {
            logResponse(urlResponse, data: data)
        }
        
        if let unwrappedError = error {
            sendError(NSError(domain: "RestFetcher", code: unwrappedError._code, userInfo: ["time": "\(responseTime)",
                "message": "Network Error"]))
        } else  if isSuccessCode(urlResponse.statusCode) {
            let restResponse = RFResponse(headers: extractHeaders(urlResponse: urlResponse),
                                          code: urlResponse.statusCode,
                                          data: data,
                                          responseTime: responseTime)
            sendSuccess(restResponse)
        } else {
            let headers = extractHeaders(urlResponse: urlResponse)
            let userInfo: [String: Any] = ["time": "\(responseTime)",
                "message": dataToString(data),
                "headers": headers]
            sendError(NSError(domain: "RestFetcher", code: urlResponse.statusCode, userInfo: userInfo))
        }
    }
    
    private func calculateResponseTimeInSeconds() -> Double {
        let endTime = DispatchTime.now().uptimeNanoseconds
        let responseTimeInNanoSeconds = endTime - startTime
        let nanoSecondsInOneSecond = 1_000_000_000
        return Double(responseTimeInNanoSeconds) / Double(nanoSecondsInOneSecond)
    }
    
    private func extractHeaders(urlResponse: HTTPURLResponse) -> [String: String] {
        if let headers = urlResponse.allHeaderFields as? [String: String] {
            return headers
        } else {
            return [:]
        }
    }
    
    private func sendError(_ error: NSError) {
        DispatchQueue.main.async { [weak self] in
            self?.errorCallback(error)
        }
    }
    
    private func sendSuccess(_ response: RFResponse) {
        DispatchQueue.main.async { [weak self] in
            self?.successCallback(response)
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
        if let data = body {
            updatedRequest.httpBody = data
        }
        return updatedRequest
    }
    
    private func logRequest(_ request: URLRequest) {
        
        var logMessage = "Request: \(hashValue) \(method.rawValue)\nURL: \(String(describing: resource))\n Headers:\n"
        for (key, val) in headers {
            logMessage += "\t\(key): \(val)\n"
        }
        if let data = body {
            logMessage += "Body: \(String(describing: String(data: data, encoding: .utf8)))"
        }
        logger.debug(logMessage)
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        
        var logMessage = "Response: \(hashValue) \(method.rawValue) received: \(response.statusCode)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)\n"
        }
        if let data = body {
            logMessage += "Body: \(String(describing: String(data: data, encoding: .utf8)))"
        }
        logger.debug(logMessage)
    }
    
    private func dataToString(_ data: Data?) -> String {
        var output = ""
        if let unwrappedData = data {
            if let str = String(data: unwrappedData, encoding: .utf8) {
                output = str as String
            }
        }
        return output
    }
    
    private func isSuccessCode(_ code: Int) -> Bool {
        return code >= 200 && code <= 299
    }
    
}
