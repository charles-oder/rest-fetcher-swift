import XCTest
@testable import RestFetcher

class RestFetcherTests: XCTestCase {
    
    var testObject : RestFetcher?

    override func setUp() {
        let headers : Dictionary<String, String> = ["header1":"one", "header2":"two"]
        let method = RestMethod.POST
        let body = "{\"thing\":\"one\", \"otherThing\":\"two\"}"
        testObject = RestFetcher(resource: "http://google.com/api/login", method: method, headers: headers, body: body, successCallback: {(response:RestResponse) in }, errorCallback: {(error:NSError) in })
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testResourceUrl() {
        let actualUrl = self.testObject!.createRequest().URL
        let expectedUrl = NSURL(string: "http://google.com/api/login")
        XCTAssertEqual(actualUrl, expectedUrl!)
    }
    
    func testRestMethod() {
        let expectedMethod = RestMethod.POST
        let actualMethod = testObject!.createRequest().HTTPMethod
        XCTAssertEqual(actualMethod!, expectedMethod.getString())
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
        let asyncExpectation = expectationWithDescription("ApiCall")
        var errorFlag = false
        self.testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
            XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, 400)
                XCTAssertEqual("Refused Connection", (error.userInfo["message"] as! String))
                asyncExpectation.fulfill()
              errorFlag = true
            })
        
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 400, HTTPVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let str = "Refused Connection"
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        self.testObject?.urlSessionComplete(data, response: mockResponse, error: nil)
        
        waitForExpectationsWithTimeout(3){error in
            XCTAssertNil(error, "test Timed Out")
        }

        XCTAssertTrue(errorFlag)
    }
    
    func test200Response() {
        var successFlag = false
        let asyncExpectation = expectationWithDescription("ApiCall")
        self.testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTAssertEqual(RestResponseCode.OK, response.code)
                let actualBody = response.body
                XCTAssertEqual(actualBody, "{\"thing\":\"one\"}")
                XCTAssertEqual("value1", response.headers["header1"])
                XCTAssertEqual("value2", response.headers["header2"])
                successFlag = true
                asyncExpectation.fulfill()
            }, errorCallback: {(error:NSError) in
                XCTFail("Should not have been called")
            })
        
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: ["header1":"value1", "header2":"value2"])
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        self.testObject?.urlSessionComplete(data, response: mockResponse, error: nil)
        
        waitForExpectationsWithTimeout(3){error in
            XCTAssertNil(error, "test Timed Out")
        }
            XCTAssertTrue(successFlag)
   }
    
    func testErrorResponse() {
        let asyncExpectation = expectationWithDescription("ApiCall")
        var errorFlag = false
        self.testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as! String))
                errorFlag = true
                asyncExpectation.fulfill()
            })
        
        let mockResponse = NSHTTPURLResponse(URL: NSURL(string:"")!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        self.testObject?.urlSessionComplete(data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
        
        waitForExpectationsWithTimeout(3){error in
            XCTAssertNil(error, "test Timed Out")
        }
        XCTAssertTrue(errorFlag)
    }
    
    func testNonNSHTTPURLResponse() {
        testObject = RestFetcher(resource: "", method: RestMethod.GET, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, 999)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as! String))
        })
        let mockResponse = NSURLResponse()
        let data = "{\"thing\":\"one\"}".dataUsingEncoding(NSUTF8StringEncoding)
        testObject?.urlSessionComplete(data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
    }
    
    func testFetch() {
        class mockTask : NSURLSessionDataTask {
            var resumeCalled = false
            private override func resume() {
                resumeCalled = true
            }
        }
        class mockSession : NSURLSession {
            let headers : Dictionary<String, String> = ["header1":"one", "header2":"two"]
            var dataTaskCalled = false
            var urlRequest :NSURLRequest?
            var mockTaskObject = mockTask()
            private override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
                urlRequest = request
                dataTaskCalled = true
                XCTAssertEqual("{\"thing\":\"one\", \"otherThing\":\"two\"}", NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
                XCTAssertEqual("POST", request.HTTPMethod)
                for (key, value) in request.allHTTPHeaderFields! {
                    XCTAssertEqual(headers[key], value)
                }
                return mockTaskObject
            }
        }
        let mockSessionObject = mockSession()
        testObject!.setUrlSession(mockSessionObject)
        testObject?.fetch()
        
        XCTAssertTrue(mockSessionObject.dataTaskCalled)
        XCTAssertTrue(mockSessionObject.mockTaskObject.resumeCalled)
    }
    
}
