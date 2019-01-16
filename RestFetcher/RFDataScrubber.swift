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
    
    private func scrub(json: String?, key: String) throws -> String? {
        guard let json = json, !json.isEmpty else {
            return ""
        }
        var body = json
        let regex = try NSRegularExpression(pattern: "\\\"[^\"]*\(key)[^\"]?\\\"\\s*:\\s*\\\"", options: NSRegularExpression.Options.caseInsensitive)
        let range = NSRange(location: 0, length: body.count)
        let matches = regex.matches(in: body, options: [], range: range).reversed()
        
        for match in matches {
            var split = body.split(at: match.range.upperBound)
            let first = split[0]
            var second = split[1]
            while !second.hasPrefix("\"") {
                second = String(second.dropFirst())
            }
            body = first + "********" + second
        }
        return body
    }
    
    private func scrub(json: String?, keys: [String]) throws -> String? {
        var body = json
        for key in keys {
            body = try scrub(json: body, key: key)
        }
        return body
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
