//
//  RestFetcherLogger.swift
//  RestFetcher
//
//  Created by Charles Oder on 5/26/16.
//  Copyright © 2016 Charles Oder. All rights reserved.
//

import UIKit

@objc
public protocol RestFetcherLogger {
    func logRequest(callId: String, url: String?, headers: [String:String], body: String?)
    func logResponse(callId: String, url: String?, code: Int, headers: [String:String], body: String?)
}
