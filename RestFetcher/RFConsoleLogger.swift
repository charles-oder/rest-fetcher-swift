//
//  ConsoleLogger.swift
//  RestFetcher
//
//  Created by Charles Oder on 5/26/16.
//  Copyright © 2016 Charles Oder. All rights reserved.
//

import UIKit

@objc
public protocol RFLogger {
    func debug(_ message: String)
    func error(_ message: String)
}

@objc
public class RFConsoleLogger: NSObject, RFLogger {

    public func debug(_ message: String) {
        print("DEBUG: \(message)")
    }
    
    public func error(_ message: String) {
        print("ERROR: \(message)")
    }
    
}
