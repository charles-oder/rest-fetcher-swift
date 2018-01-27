//
//  RestFetcherEnvironemnt.swift
//  RestFetcher
//
//  Created by Charles Oder on 4/5/16.
//  Copyright © 2016 Charles Oder. All rights reserved.
//

import UIKit

class RFEnvironemnt: NSObject {

    func isLogging() -> Bool {
        if let value = getInfoPlistDictionary()?["log_rest_fetcher_calls"] as? Bool {
            return value
        }
        return false
    }
    
    func getInfoPlistDictionary() -> NSDictionary? {
        var plist: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            plist = NSDictionary(contentsOfFile: path)
        }
        return plist
    }

}
