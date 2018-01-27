//
//  RFDataScrubber.swift
//  Pods-RestFetcherExample
//
//  Created by Charles Oder DTN on 1/27/18.
//

import Foundation

public class RFDataScrubber {
    
    private let keysToScrub: [String]
    
    public init(keysToScrub: [String]) {
        self.keysToScrub = keysToScrub
    }
    
    public func scrub(json: String?) -> String? {
        let data = json?.data(using: String.Encoding.utf8, allowLossyConversion: true)
        if let data = data {
            do {
                let options = JSONSerialization.ReadingOptions.allowFragments
                if let parsedJSON = try JSONSerialization.jsonObject(with: data,
                                                                     options: options) as? [String: AnyObject] {
                    let strippedJson = scrub(dictionary: parsedJSON)
                    let strippedData = try JSONSerialization.data(withJSONObject: strippedJson, options: .prettyPrinted)
                    let strippedString = String(data: strippedData, encoding: .utf8) ?? ""
                    return strippedString
                }
            } catch let error {
                print("Error Stripping data from JSON: \(error)")
                return json
            }
        }
        return json
    }
    
    public func scrub(dictionary: [String: Any]) -> [String: Any] {
        var output = dictionary
        for (key, val) in dictionary {
            if key.containsAny(strings: keysToScrub) {
                output[key] = "********" as AnyObject?
            }
            if let dictVal = val as? [String: AnyObject] {
                output[key] = scrub(dictionary: dictVal) as AnyObject?
            }
        }
        return output
    }
}

extension String {
    func containsAny(strings: [String]) -> Bool {
        for string in strings {
            if lowercased().contains(string.lowercased()) {
                return true
            }
        }
        return false
    }
}
