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
    
    let testJson = "{\"boolKey\":true,\"stringKey\":\"stringValue\",\"intKey\":42,\"objectKey\":{\"stringKey\":\"objectStringValue\",\"intKey\":43},\"objectArrayKey\":[{\"stringKey\":\"arrayObjectString1\",\"intKey\":1},{\"stringKey\":\"arrayObjectString2\",\"intKey\":2},{\"stringKey\":\"arrayObjectString3\",\"intKey\":3}]}"
    
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
        
        XCTAssertEqual(5, payload.count)
    }
    
    func testGetDictionaryPayloadCreatedWithJsonString() {
        let testObject = JsonParser(json: testJson)
        
        let payload = testObject.getDictionaryPayload()
        
        XCTAssertEqual(5, payload.count)
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
    
    
}
