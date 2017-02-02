import XCTest
@testable import RestFetcher

class RestFetcherTests: XCTestCase {
    
    var testObject : RestFetcher?

    override func setUp() {
        let headers : Dictionary<String, String> = ["header1":"one", "header2":"two"]
        let method = RestMethod.post
        let body = "{\"thing\":\"one\", \"otherThing\":\"two\"}"
        testObject = RestFetcher(resource: "http://google.com/api/login", method: method, headers: headers, body: body, successCallback: {(response:RestResponse) in }, errorCallback: {(error:NSError) in })
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testResourceUrl() {
        let actualUrl = self.testObject!.createRequest().url
        let expectedUrl = URL(string: "http://google.com/api/login")
        XCTAssertEqual(actualUrl, expectedUrl!)
    }
    
    func testRestMethod() {
        let expectedMethod = RestMethod.post
        let actualMethod = testObject!.createRequest().httpMethod
        XCTAssertEqual(actualMethod!, expectedMethod.getString())
    }
    
    func testHeaders() {
        let expectedHeaders : Dictionary<String, String> = ["header1":"one", "header2":"two"]
        var request = testObject!.createRequest()
        if let headers = request.allHTTPHeaderFields {
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
        let expectedBody = "{\"thing\":\"one\", \"otherThing\":\"two\"}".data(using: String.Encoding.utf8)
        let actualBody = testObject!.createRequest().httpBody
        XCTAssert(actualBody == expectedBody, "Bodies don't match: \(NSString(data: actualBody!, encoding: String.Encoding.utf8.rawValue))")
    }
    
    func test400Response() {
        let asyncExpectation = expectation(description: "ApiCall")
        var errorFlag = false
        self.testObject = RestFetcher(resource: "", method: RestMethod.get, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
            XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, 400)
                XCTAssertEqual("Refused Connection", (error.userInfo["message"] as! String))
                asyncExpectation.fulfill()
              errorFlag = true
            })
        
        let mockResponse = HTTPURLResponse(url: URL(string:"https://google.com")!, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let str = "Refused Connection"
        let data = str.data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data, response: mockResponse, error: nil)
        
        waitForExpectations(timeout: 3){error in
            XCTAssertNil(error, "test Timed Out")
        }

        XCTAssertTrue(errorFlag)
    }
    
    func test200Response() {
        var successFlag = false
        let asyncExpectation = expectation(description: "ApiCall")
        self.testObject = RestFetcher(resource: "", method: RestMethod.get, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
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
        
        let mockResponse = HTTPURLResponse(url: URL(string:"https://google.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["header1":"value1", "header2":"value2"])
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data, response: mockResponse, error: nil)
        
        waitForExpectations(timeout: 3){error in
            XCTAssertNil(error, "test Timed Out")
        }
            XCTAssertTrue(successFlag)
   }
    
    func testErrorResponse() {
        let asyncExpectation = expectation(description: "ApiCall")
        var errorFlag = false
        self.testObject = RestFetcher(resource: "", method: RestMethod.get, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as! String))
                errorFlag = true
                asyncExpectation.fulfill()
            })
        
        let mockResponse = HTTPURLResponse(url: URL(string:"https://google.com")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: Dictionary<String, String>())
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
        
        waitForExpectations(timeout: 3){error in
            XCTAssertNil(error, "test Timed Out")
        }
        XCTAssertTrue(errorFlag)
    }
    
    func testNonNSHTTPURLResponse() {
        testObject = RestFetcher(resource: "", method: RestMethod.get, headers: Dictionary<String, String>(), body: "", successCallback: {(response:RestResponse) in
                XCTFail("Should not have been called")
            }, errorCallback: {(error:NSError) in
                XCTAssertEqual(error.code, 999)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as! String))
        })
        let mockResponse = URLResponse()
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        testObject?.urlSessionComplete(data: data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
    }
    
    func testFetch() {
        class mockTask : URLSessionDataTask {
            var resumeCalled = false
            fileprivate override func resume() {
                resumeCalled = true
            }
        }
        class mockSession : URLSession {
            let headers : Dictionary<String, String> = ["header1":"one", "header2":"two"]
            var dataTaskCalled = false
            var urlRequest :URLRequest?
            var mockTaskObject = mockTask()
            
            fileprivate override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                urlRequest = request
                dataTaskCalled = true
                XCTAssertEqual("{\"thing\":\"one\", \"otherThing\":\"two\"}", NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue))
                XCTAssertEqual("POST", request.httpMethod)
                for (key, value) in request.allHTTPHeaderFields! {
                    XCTAssertEqual(headers[key], value)
                }
                return mockTaskObject
            }
        }
        let mockSessionObject = mockSession()
        testObject!.setUrlSession(session: mockSessionObject)
        testObject?.fetch()
        
        XCTAssertTrue(mockSessionObject.dataTaskCalled)
        XCTAssertTrue(mockSessionObject.mockTaskObject.resumeCalled)
    }
    
}
