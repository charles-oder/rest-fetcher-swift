import XCTest

class RestResponseTests: XCTestCase {
    
    func testCreateResponseWithValidJson() {
        let testJsonData = "{\"key1\":\"value1\"}"
        
        let testObject = RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.OK, body: testJsonData)
        
        XCTAssertNotNil(testObject.json)
        XCTAssertEqual("value1", testObject.json["key1"])
        XCTAssertNil(testObject.jsonParseError)
    }
    
    func testCreateResponseWithInvalidJson() {
        let testJson = "booga booga"
        
        let testObject = RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.OK, body: testJson)
        
        XCTAssertNotNil(testObject.jsonParseError)
        XCTAssertEqual("NSCocoaErrorDomain", testObject.jsonParseError!.domain)
        XCTAssertEqual(3840, testObject.jsonParseError!.code)
        XCTAssertEqual("Invalid value around character 0.", testObject.jsonParseError!.userInfo["NSDebugDescription"] as? String)
        XCTAssertEqual(0, testObject.json.count)
    }
        
}
