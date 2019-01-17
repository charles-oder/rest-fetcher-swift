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
    
    public func scrub(json: String?) throws -> String? {
        guard let json = json, !json.isEmpty else {
            return ""
        }
        return try scrub(json: json, keys: keysToScrub)
    }
    
    private func scrub(json: String?, keys: [String]) throws -> String? {
        guard let json = json, !json.isEmpty else {
            return ""
        }
        var body = json
        let keyRegex = createKeyMatchRegex(keys: keys)
        let regex = try NSRegularExpression(pattern: "\\\"[^\"]*\(keyRegex)[^\"]?\\\"\\s*:\\s*\\\"",
                                            options: NSRegularExpression.Options.caseInsensitive)
        let range = NSRange(location: 0, length: body.count)
        let matches = regex.matches(in: body, options: [], range: range).reversed()
        
        for match in matches {
            body = removeSesitiveValue(regexMatch: match, json: body)
        }
        return body
    }
    
    func removeSesitiveValue(regexMatch: NSTextCheckingResult, json: String) -> String {
        var split = json.split(at: regexMatch.range.upperBound)
        let first = split[0]
        let second = split[1]
        guard let quoteIndex = second.firstIndex(of: "\"") else {
            return json
        }
        let cleanedSecond = second[quoteIndex...]
        
        return first + "********" + cleanedSecond
    }
    
    func createKeyMatchRegex(keys: [String]) -> String {
        var keyString = "["
        for key in keys {
            if keyString.count > 1 {
                keyString += " | "
            }
            keyString += key
        }
        keyString += "]"
        return keyString
    }
}

extension String {
    func split(at index: Int) -> [String] {
        let strIndex = self.index(self.startIndex, offsetBy: index)
        let firstString = self[..<strIndex]
        let secondString = self[strIndex...]
        return [String(firstString), String(secondString)]
    }

}
