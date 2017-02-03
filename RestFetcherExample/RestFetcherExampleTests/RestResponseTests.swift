import XCTest
@testable import RestFetcher

class RestResponseTests: XCTestCase {
    
    func testCreateResponseWithValidStringBody() {
        let testJsonData = "{\"key1\":\"value1\"}"
        
        let testObject = RestResponse(headers: [String: String](),
                                      code: RestResponseCode.ok,
                                      data: testJsonData.data(using: String.Encoding.utf8))
        
        XCTAssertNotNil(testObject.data)
        XCTAssertEqual("{\"key1\":\"value1\"}", testObject.body)
    }
    
}
