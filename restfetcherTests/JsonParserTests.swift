//
//  JsonParserTests.swift
//  Complete
//
//  Created by Charles Oder on 2/5/16.
//  Copyright © 2016 Telvent DTN. All rights reserved.
//

import XCTest
@testable import RestFetcher

class JsonParserTests: XCTestCase {
    
    let testJson = "{\"boolKey\":true,\"doubleKey\":33.333,\"doubleArrayKey\":[11.11,22.22,33.33],\"stringKey\":\"stringValue\",\"intKey\":42,\"objectKey\":{\"stringKey\":\"objectStringValue\",\"intKey\":43},\"objectArrayKey\":[{\"stringKey\":\"arrayObjectString1\",\"intKey\":1},{\"stringKey\":\"arrayObjectString2\",\"intKey\":2},{\"stringKey\":\"arrayObjectString3\",\"intKey\":3}]}"
    
    let testJsonDictionary:[String: AnyObject] = ["stringKey":"stringValue","intKey":42,"objectKey":["stringKey":"objectStringValue","intKey":43], "objectArrayKey":[["stringKey":"arrayObjectString1","intKey":1],["stringKey":"arrayObjectString2","intKey":2],["stringKey":"arrayObjectString3","intKey":3]]]
    
    func testGetDictionaryPayloadCreatedWithDictionary() {
        let testObject = JsonParser(dictionary: testJsonDictionary)
        
        let payload = testObject.getDictionaryPayload()
        
        XCTAssertEqual(4, payload.count)
    }
    
    func testGetDictionaryPayloadCreatedWithData() {
        let data = testJson.dataUsingEncoding(NSUTF8StringEncoding)!
        let testObject = JsonParser(data: data)
        
        let payload = testObject.getDictionaryPayload()
        
        XCTAssertEqual(7, payload.count)
    }
    
    func testGetDictionaryPayloadCreatedWithJsonString() {
        let testObject = JsonParser(json: testJson)
        
        let payload = testObject.getDictionaryPayload()
        
        XCTAssertEqual(7, payload.count)
    }
    
    func testGetDictionaryWithBadJsonString() {
        let data = "{\"string\":\"value\",\"huh?\":}".dataUsingEncoding(NSUTF8StringEncoding)!
        let testObject = JsonParser(data: data)
        
        let payload = testObject.getDictionaryPayload()
        
        XCTAssertEqual(0, payload.count)
    }
    
    func testGetStringForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getString(key:"stringKey")
        
        XCTAssertEqual("stringValue", value!)
    }
    
    func testGetStringValueForExistingKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getStringValue(key:"stringKey")
        
        XCTAssertEqual("stringValue", value)
    }
    
    func testGetStringValueForNonExistingKey() {
        let testObject = JsonParser(json: "{}")
        
        let value = testObject.getStringValue(key:"stringKey")
        
        XCTAssertEqual("", value)
    }
    
    func testGetIntForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getInt(key:"intKey")
        
        XCTAssertEqual(42, value!)
    }
    
    func testGetIntValueForExistingKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getIntValue(key:"intKey")
        
        XCTAssertEqual(42, value)
    }
    
    func testGetIntValueForNonExistingKey() {
        let testObject = JsonParser(json: "{}")
        
        let value = testObject.getIntValue(key:"intKey")
        
        XCTAssertEqual(0, value)
    }
    
    func testGetBoolForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getBool(key:"boolKey")
        
        XCTAssertTrue(value!)
    }
    
    func testGetBoolValueForExistingKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getBoolValue(key:"boolKey")
        
        XCTAssertTrue(value)
    }
    
    func testGetBoolValueForNonExistingKey() {
        let testObject = JsonParser(json: "{}")
        
        let value = testObject.getBoolValue(key:"boolKey")
        
        XCTAssertFalse(value)
    }
    
    func testGetObjectForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getObject(key:"objectKey")
        
        XCTAssertNotNil(value)
        XCTAssertEqual("objectStringValue", value?.getString(key: "stringKey"))
        XCTAssertEqual(43, value?.getInt(key: "intKey"))
    }
    
    func testGetObjectArrayForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getObjectArray(key:"objectArrayKey")
        
        XCTAssertNotNil(value)
        XCTAssertEqual("arrayObjectString1", value![0].getString(key: "stringKey"))
        XCTAssertEqual(1, value![0].getInt(key: "intKey"))
        XCTAssertEqual("arrayObjectString2", value![1].getString(key: "stringKey"))
        XCTAssertEqual(2, value![1].getInt(key: "intKey"))
        XCTAssertEqual("arrayObjectString3", value![2].getString(key: "stringKey"))
        XCTAssertEqual(3, value![2].getInt(key: "intKey"))
    }
    
    func testGetStringArrayForKey() {
        let json = "{\"strings\":[\"string 1\",\"string 2\",\"string 3\"]}"
        let testObject = JsonParser(json: json)
        
        let values = testObject.getStringArray(key:"strings")
        
        XCTAssertEqual(3, values.count)
        XCTAssertEqual("string 1", values[0])
        XCTAssertEqual("string 2", values[1])
        XCTAssertEqual("string 3", values[2])
    }
    
    func testGetIntArrayForKey() {
        let json = "{\"ints\":[1,2,3]}"
        let testObject = JsonParser(json: json)
        
        let values = testObject.getIntArray(key:"ints")
        
        XCTAssertEqual(3, values.count)
        XCTAssertEqual(1, values[0])
        XCTAssertEqual(2, values[1])
        XCTAssertEqual(3, values[2])
    }
    
    func testGetDoubleForKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getDouble(key:"doubleKey")
        
        XCTAssertEqual(33.333, value!)
    }
    
    func testGetDoubleValueForExistingKey() {
        let testObject = JsonParser(json: testJson)
        
        let value = testObject.getDoubleValue(key:"doubleKey")
        
        XCTAssertEqual(33.333, value)
    }
    
    func testGetIDoubleValueForNonExistingKey() {
        let testObject = JsonParser(json: "{}")
        
        let value = testObject.getDoubleValue(key:"doubleKey")
        
        XCTAssertEqual(0, value)
    }

    
    func testGetDoubleArrayForKey() {
        let json = "{\"doubles\":[11.11,22.22,33.33]}"
        let testObject = JsonParser(json: json)
        
        let values = testObject.getDoubleArray(key:"doubles")
        
        XCTAssertEqual(3, values.count)
        XCTAssertEqual(11.11, values[0])
        XCTAssertEqual(22.22, values[1])
        XCTAssertEqual(33.33, values[2])
    }
    
    func testGetDoubleArrayForNonExistingKey() {
        let json = "{}"
        let testObject = JsonParser(json: json)
        
        let values = testObject.getDoubleArray(key:"doubles")
        
        XCTAssertEqual(0, values.count)
    }
    

}
