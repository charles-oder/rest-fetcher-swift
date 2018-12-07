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

extension RFRequest: RFLoggedRequest {
    
    func logResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) {
        guard let unwrappedData = data else {
            return
        }
        
        let body = String(data: unwrappedData, encoding: .utf8)
        logger.debug(buildSuccessMessage(responseTime: responseTime, code: code, headers: headers, data: data, body: body))
    }
    
    func logError(_ error: NSError) {
        logger.error(buildErrorMessage(error: error))
    }
    
    func logRequest(resource: String, method: RFMethod, headers: [String: String], body: String) {
        logger.debug(buildRequestLogMessage())
    }
    
    func buildRequestLogMessage() -> String {
        var logMessage = "Sending Request: \(requestId)\n\(restMethod.rawValue) Request: \(requestUrlString)\n Request Headers:\n"
        for (key, val) in requestHeaders {
            logMessage += "\t\(key): \(val)\n"
        }
        do {
            let requestBodyLogMessageScrubbed = try RFDataScrubber(keysToScrub: keysToScrub).scrub(json: requestBody) ?? ""
            logMessage += "Request Body: \(requestBodyLogMessageScrubbed)\n"
            return logMessage
        } catch {
            logMessage += "Request Body: Error scrubbing requestBody\(error)\n"
            return logMessage
        }
    }

    //swiftlint:disable line_length
    func buildSuccessMessage(responseTime: Double, code: Int, headers: [String: String], data: Data?, body: String?) -> String {
        let responseTimeString = String(format: "%.6f", responseTime)
        var logMessage = "Response Recieved: \(requestId)\n\(restMethod.rawValue): \(requestUrlString)\nResponse took \(responseTimeString) seconds\nResponse: \(code)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)"
        }
        do {
            let responseBodyMessageScrubbed = try RFDataScrubber(keysToScrub: keysToScrub).scrub(json: body) ?? ""
            logMessage += "\nResponse Body: \(responseBodyMessageScrubbed)"
            return logMessage
        } catch {
            logMessage += "Response Body: Error scrubbing response\(error)\n"
            return logMessage
        }
    }
    
    func buildErrorMessage(error: NSError) -> String {
        let responseTimeString = error.userInfo["time"] as? String ?? "<unknown>"
        var logMessage = "Response Recieved: \(requestId)\n\(restMethod.rawValue): \(requestUrlString)\nResponse took \(responseTimeString) seconds\nResponse: \(error.code)\n"
        let headers = error.userInfo["headers"] as? [String: String]
        logMessage += "\nResponse Headers:"
        for (key, value) in headers ?? [:] {
            logMessage += "\n\(key): \(value)"
        }
        logMessage += "\nResponse Body: \(error.userInfo["message"] ?? "")"
        return logMessage
    }
    //swiftlint:enable line_length
    
}
