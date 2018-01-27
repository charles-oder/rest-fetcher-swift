import XCTest
@testable import RestFetcher

class RFResponseTests: XCTestCase {
    
    func testCreateResponseWithValidStringBody() {
        let testJsonData = "{\"key1\":\"value1\"}"
        
        let testObject = RFResponse(headers: [String: String](),
                                      code: 200,
                                      data: testJsonData.data(using: String.Encoding.utf8))
        
        XCTAssertNotNil(testObject.data)
        XCTAssertEqual("{\"key1\":\"value1\"}", testObject.body)
    }
    
}
