import XCTest

class RestFetcherTests: XCTestCase {
    
    var testObject : RestFetcher?

    override func setUp() {
        let headers : Dictionary<String, String> = ["header1":"one", "header2":"two"]
        let method = RestMethod.POST
        let body = "{\"thing\":\"one\", \"otherThing\":\"two\"}"
        testObject = RestFetcher(resource: "http://google.com/api/login", method: method, headers: headers, body: body, successCallback: {(response:RestResponse) in }, errorCallback: {(error:RestError) in })
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testResourceUrl() {
        let actualUrl = self.testObject!.getUrl()
        let expectedUrl = NSURL(string: "http://google.com/api/login")
        XCTAssertEqual(actualUrl, expectedUrl!)
    }
    
    func testRestMethod() {
        let expectedMethod = RestMethod.POST
        let actualMethod = testObject!.createRequest().HTTPMethod
        XCTAssertEqual(actualMethod!, expectedMethod.rawValue)
    }
    
    func testHeaders() {
        let expectedHeaders : Dictionary<String, String> = ["header1":"one", "header2":"two"]
        let request = testObject!.createRequest().mutableCopy()
        if let headers = request.allHTTPHeaderFields! {
            for (key, value) in expectedHeaders {
                if let s = headers[key] {
                XCTAssertEqual(value, s)
                } else {
                    XCTFail("Key missing: \(key)")
                }
            }
        } else {
            XCTFail("No Headers found")
        }
    }
    
    func testBody() {
        let expectedBody = "{\"thing\":\"one\", \"otherThing\":\"two\"}".dataUsingEncoding(NSUTF8StringEncoding)
        let actualBody = testObject!.createRequest().HTTPBody
        XCTAssert(actualBody == expectedBody, "Bodies don't match: \(NSString(data: actualBody!, encoding: NSUTF8StringEncoding))")
    }
    
    func test400Response() {
        var errorFlag = false
        testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
            XCTFail("Should not have been called")
            }, errorCallback: {(error:RestError) in
                XCTAssertEqual(error.code, 400)
                XCTAssertEqual("Refused Connection", error.reason)
              errorFlag = true
            })
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 400, HTTPVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let str = "Refused Connection"
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        testObject?.urlSessionComplete(data, response: mockResponse, error: nil)
        XCTAssertTrue(errorFlag)
    }
    
    func test200Response() {
        var successFlag = false
        testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTAssertEqual(RestResponseCode.OK, response.code)
                let actualBody = response.body
                XCTAssertEqual(actualBody, "{\"thing\":\"one\"}")
                successFlag = true
            }, errorCallback: {(error:RestError) in
                XCTFail("Should not have been called")
            })
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        testObject?.urlSessionComplete(data, response: mockResponse, error: nil)
        XCTAssertTrue(successFlag)
   }
    
    func testErrorResponse() {
        var errorFlag = false
        testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:RestError) in
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual("Network Error", error.reason)
                errorFlag = true
            })
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        testObject?.urlSessionComplete(data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
        XCTAssertTrue(errorFlag)
    }
    
    func testNonNSHTTPURLResponse() {
        testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:RestError) in
                XCTAssertEqual(error.code, 999)
                XCTAssertEqual("Network Error", error.reason)
        })
        let mockResponse = NSURLResponse()
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        testObject?.urlSessionComplete(data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
    }
    
}
