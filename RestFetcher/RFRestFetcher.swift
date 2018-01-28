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
    
    private let logger: RFLogger
    private let timeout: TimeInterval
    private let resource: String!
    private let method: RFMethod!
    private let headers: [String: String]
    private let body: String?
    private let successCallback: (_ response: RFResponse) -> Void
    private let errorCallback: (_ error: NSError) -> Void
    private var session: URLSession = URLSession.shared

    private var startTime: UInt64 = 0

    public init(resource: String,
                method: RFMethod,
                headers: [String: String],
                body: String,
                logger: RFLogger = RFConsoleLogger(),
                timeout: TimeInterval = 30,
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
        let task = session.dataTask(with: createRequest(), completionHandler: urlSessionComplete)
        startTime = DispatchTime.now().uptimeNanoseconds
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
        
        let responseTime = calculateResponseTimeInSeconds()
        guard let urlResponse = response as? HTTPURLResponse else {
            sendError(NSError(domain: "RestFetcher", code: 0, userInfo: ["time": "\(responseTime)",
                                                                        "message": "Network Error"]))
            return
        }
        
        if RFEnvironemnt().isLogging() {
            logResponse(urlResponse, data: data)
        }
        
        if let e = error {
            sendError(NSError(domain: "RestFetcher", code: e._code, userInfo: ["time": "\(responseTime)",
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
        
        var logMessage = "Request: \(hashValue) \(method.rawValue)\nURL: \(String(describing: resource))\n Headers:\n"
        for (key, val) in headers {
            logMessage += "\t\(key): \(val)\n"
        }
        logMessage += "Body: \(String(describing: body))"
        logger.debug(logMessage)
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        
        var logMessage = "Response: \(hashValue) \(method.rawValue) received: \(response.statusCode)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)"
        }
        logMessage += "\nBody: \(String(describing: body))"
        logger.debug(logMessage)
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
