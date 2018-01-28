//
//  RFLoggedRequest.swift
//  Pods-RestFetcherExample
//
//  Created by Charles Oder DTN on 1/27/18.
//

import Foundation

public protocol RFLoggedRequest {
    var logger: RFLogger { get }
    var keysToScrub: [String] { get }
}

extension RFLoggedRequest {
    public var logger: RFLogger {
        return RFConsoleLogger()
    }
    
    public var keysToScrub: [String] {
        return ["password"]
    }
    
}

extension RFRequest: RFLoggedRequest {
    
    func logResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) {
        guard let unwrappedData = data else {
            return
        }
        
        let body = String(data: unwrappedData, encoding: .utf8)
        let message = buildSuccessMessage(code: code, headers: headers, data: data, body: body)
        logger.debug("rest_call: \(message)")
    }
    
    func logError(_ error: NSError) {
        let errorMessage = buildErrorMessage(error: error)
        logger.error("rest_error: \(errorMessage)")
    }
    
    func logRequest(resource: String, method: RFMethod, headers: [String: String], body: String) {
        logger.debug(buildRequestLogMessage())
    }
    
    func buildRequestLogMessage() -> String {
        var logMessage = "\(requestId) \(restMethod.rawValue) Request: \(requestUrlString)\n Request Headers:\n"
        for (key, val) in requestHeaders {
            logMessage += "\t\(key): \(val)\n"
        }
        logMessage += "Request Body: \(RFDataScrubber(keysToScrub: keysToScrub).scrub(json: requestBody) ?? "")\n"
        return logMessage
    }
    
    func buildSuccessMessage(code: Int, headers: [String: String], data: Data?, body: String?) -> String {
        var logMessage = "\(requestId) Response: \(code)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)"
        }
        logMessage += "\nResponse Body: \(RFDataScrubber(keysToScrub: keysToScrub).scrub(json: body) ?? "")"
        return logMessage
        
    }
    
    func buildErrorMessage(error: NSError) -> String {
        var logMessage = "\(requestId) Response: \(error.code)\n"
        let headers = error.userInfo["headers"] as? [String: String]
        logMessage += "\nResponse Headers:"
        for (key, value) in headers ?? [:] {
            logMessage += "\n\(key): \(value)"
        }
        logMessage += "\nResponse Body: \(error.userInfo["message"] ?? "")"
        return logMessage
    }
    
}
