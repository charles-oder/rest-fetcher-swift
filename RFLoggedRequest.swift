//
//  RFLoggedRequest.swift
//  Pods-RestFetcherExample
//
//  Created by Charles Oder DTN on 1/27/18.
//

import Foundation

open class RFLoggedRequest<T>: RFRequest<T> {
    
    open var logger: RFLogger {
        return RFConsoleLogger()
    }
    
    open var keysToScrub: [String] {
        return ["password"]
    }
    
    open override func willCreateResponse(code: Int, headers: [String: String], data: Data?) {
        guard let unwrappedData = data else {
            return
        }
        
        let body = String(data: unwrappedData, encoding: .utf8)
        let message = buildSuccessMessage(code: code, headers: headers, data: data, body: body)
        logger.debug("rest_call: \(message)")
    }
    
    open override func onError(_ error: NSError) {
        let errorMessage = buildErrorMessage(error: error)
        logger.error("rest_error: \(errorMessage)")
        super.onError(error)
    }
    
    func buildRequestLogMessage() -> String {
        var logMessage = "\(restMethod.rawValue) Request: \(requestUrlString)\n Request Headers:\n"
        for (key, val) in requestHeaders {
            logMessage += "\t\(key): \(val)\n"
        }
        logMessage += "Request Body: \(RFDataScrubber(keysToScrub: keysToScrub).scrub(json: requestBody) ?? "")\n"
        return logMessage
    }
    
    func buildSuccessMessage(code: Int, headers: [String: String], data: Data?, body: String?) -> String {
        var logMessage = buildRequestLogMessage()
        logMessage += "Response: \(code)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)"
        }
        logMessage += "\nResponse Body: \(RFDataScrubber(keysToScrub: keysToScrub).scrub(json: body) ?? "")"
        return logMessage
        
    }
    
    func buildErrorMessage(error: NSError) -> String {
        var logMessage = buildRequestLogMessage()
        logMessage += "Response: \(error.code)\n"
        let headers = error.userInfo["headers"] as? [String: String]
        logMessage += "\nResponse Headers:"
        for (key, value) in headers ?? [:] {
            logMessage += "\n\(key): \(value)"
        }
        logMessage += "\nResponse Body: \(error.userInfo["message"] ?? "")"
        return logMessage
    }
    
}
