import XCTest

class RestResponseTests: XCTestCase {
    
    func testCreateResponseWithValidStringBody() {
        let testJsonData = "{\"key1\":\"value1\"}"
        
        let testObject = RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.OK, data: testJsonData.dataUsingEncoding(NSUTF8StringEncoding))
        
        XCTAssertNotNil(testObject.data)
        XCTAssertEqual("{\"key1\":\"value1\"}", testObject.body)
    }
    
}
