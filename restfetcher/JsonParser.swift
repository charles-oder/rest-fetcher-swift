//
//  JsonParser.swift
//  Complete
//
//  Created by Charles Oder on 2/5/16.
//  Copyright © 2016 Telvent DTN. All rights reserved.
//

import UIKit

public typealias Payload = [String: AnyObject]

@objc
public class JsonParser: NSObject {
    
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
    
    public func getStringArray(key key: String) -> [String] {
        if let array = _payload[key] as? [String] {
            return array
        } else {
            return []
        }
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
    
    public func getIntArray(key key: String) -> [Int] {
        if let array = _payload[key] as? [Int] {
            return array
        } else {
            return []
        }
    }
    
    public func getDouble(key key: String) -> Double? {
        return _payload[key] as? Double
    }
    
    public func getDoubleValue(key key: String) -> Double {
        if let value = getDouble(key: key) {
            return value
        } else {
            return 0.0
        }
    }
    
    public func getDoubleArray(key key: String) -> [Double] {
        if let array = _payload[key] as? [Double] {
            return array
        } else {
            return []
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
