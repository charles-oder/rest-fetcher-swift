//
//  ConsoleLogger.swift
//  RestFetcher
//
//  Created by Charles Oder on 5/26/16.
//  Copyright © 2016 Charles Oder. All rights reserved.
//

import UIKit

@objc
public class ConsoleLogger: NSObject, RestFetcherLogger {

    public func logRequest(callId: String, url: String?, headers: [String:String], body: String?) {
        var logMessage = "Request: \(callId)\nURL: \(url)\n Headers:\n"
        for (key, val) in headers {
            logMessage += "\t\(key): \(val)\n"
        }
        logMessage += "Body: \(body)"
        print(logMessage)
    }
    
    public func logResponse(callId: String, url: String?, code: Int, headers: [String:String], body: String?) {
        var logMessage = "Response: \(callId) received: \(code)\nHeaders:\n"
        for (key, val) in headers {
            logMessage += "\(key): \(val)"
        }
        logMessage += "Body: \(body)"
        print(logMessage)
    }
}
