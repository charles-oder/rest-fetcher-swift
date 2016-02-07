//
//  JsonParser.swift
//  Complete
//
//  Created by Charles Oder on 2/5/16.
//  Copyright © 2016 Telvent DTN. All rights reserved.
//

import UIKit

public typealias Payload = [String: AnyObject]

public class JsonParser {
    
    private let _payload: Payload
    
    public convenience init(json: String) {
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)!
        self.init(data:data)
    }

    public convenience init(data: NSData) {
        var payload: Payload
        do {
            payload = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! Payload
        } catch {
            print(error)
            payload = Dictionary<String, AnyObject>()
        }

        self.init(dictionary:payload)
    }
    
    public init(dictionary:Payload) {
        _payload = dictionary
    }
    
    public func getDictionaryPayload() -> Payload {
        return _payload
    }
    
    public func getString(key key: String) -> String? {
        return _payload[key] as? String
    }
    
    public func getStringValue(key key: String) -> String {
        var output = ""
        if let value = getString(key: key) {
            output = value
        }
        return output
    }
    
    public func getInt(key key: String) -> Int? {
        return _payload[key] as? Int
    }
    
    public func getIntValue(key key: String) -> Int {
        if let value = getInt(key: key) {
            return value
        } else {
            return 0
        }
    }
    
    public func getBool(key key: String) -> Bool? {
        return _payload[key] as? Bool
    }
    
    public func getBoolValue(key key: String) -> Bool {
        if let value = getBool(key: key) {
            return value
        } else {
            return false
        }
    }
    
    public func getObject(key key: String) -> JsonParser? {
        if let payload = _payload[key] as? Payload {
            return JsonParser(dictionary: payload)
        } else {
            return nil
        }
    }
    
    public func getObjectArray(key key: String) -> [JsonParser]? {
        var output: [JsonParser] = []
        if let payloadArray = _payload[key] as? [Payload] {
            for payload in payloadArray {
                output.append(JsonParser(dictionary: payload))
            }
        }
        return output
    }
    
}
