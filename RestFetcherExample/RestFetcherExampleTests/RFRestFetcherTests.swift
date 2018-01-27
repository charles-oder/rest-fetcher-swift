import XCTest
@testable import RestFetcher

class RFRestFetcherTests: XCTestCase {
    
    var testObject: RFRestFetcher?

    override func setUp() {
        let headers: [String: String] = ["header1": "one", "header2": "two"]
        let method = RFMethod.post
        let body = "{\"thing\":\"one\", \"otherThing\":\"two\"}"
        testObject = RFRestFetcher(resource: "http://google.com/api/login",
                                 method: method,
                                 headers: headers,
                                 body: body,
                                 successCallback: { _ in },
                                 errorCallback: { _ in })
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testResourceUrl() {
        let actualUrl = self.testObject?.createRequest().url
        let expectedUrl = URL(string: "http://google.com/api/login")
        XCTAssertEqual(actualUrl, expectedUrl)
    }
    
    func testRestMethod() {
        let expectedMethod = RFMethod.post
        let actualMethod = testObject?.createRequest().httpMethod
        XCTAssertEqual(actualMethod, expectedMethod.rawValue)
    }
    
    func testHeaders() {
        let expectedHeaders: [String: String] = ["header1": "one", "header2": "two"]
        guard let request = testObject?.createRequest() else {
            XCTFail("No request")
            return
        }
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
        guard let actualBody = testObject?.createRequest().httpBody else {
            XCTFail("No body")
            return
        }
        let actualBodyString = NSString(data: actualBody, encoding: String.Encoding.utf8.rawValue)
        XCTAssert(actualBody == expectedBody, "Bodies don't match: \(String(describing: actualBodyString))")
    }
    
    func test400Response() {
        let asyncExpectation = expectation(description: "ApiCall")
        var errorFlag = false
        self.testObject = RFRestFetcher(resource: "",
                                      method: RFMethod.get,
                                      headers: [String: String](), body: "",
                                      successCallback: { _ in
            XCTFail("Should not have been called")
            },
                                      errorCallback: { error in
                XCTAssertEqual(error.code, 400)
                XCTAssertEqual("Refused Connection", (error.userInfo["message"] as? String))
                let headers = error.userInfo["headers"] as? [String: String]
                XCTAssertEqual("value", headers?["field"])
                asyncExpectation.fulfill()
              errorFlag = true
            })
        
        guard let url = URL(string: "https://google.com") else {
            XCTFail("no url")
            return
        }
        let mockResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: ["field": "value"])
        let str = "Refused Connection"
        let data = str.data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data, response: mockResponse, error: nil)
        
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error, "test Timed Out")
        }

        XCTAssertTrue(errorFlag)
    }
    
    func test200Response() {
        var successFlag = false
        let asyncExpectation = expectation(description: "ApiCall")
        self.testObject = RFRestFetcher(resource: "",
                                      method: RFMethod.get,
                                      headers: [String: String](), body: "",
                                      successCallback: { response in
                XCTAssertEqual(RFResponseCode.ok, response.code)
                let actualBody = response.body
                XCTAssertEqual(actualBody, "{\"thing\":\"one\"}")
                XCTAssertEqual("value1", response.headers["header1"])
                XCTAssertEqual("value2", response.headers["header2"])
                successFlag = true
                asyncExpectation.fulfill()
            },
                                      errorCallback: { _ in
                XCTFail("Should not have been called")
            })
        
        guard let url = URL(string: "https://google.com") else {
            XCTFail("no url")
            return
        }
        let mockResponse = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: "HTTP/1.1",
                                           headerFields: ["header1": "value1", "header2": "value2"])
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data, response: mockResponse, error: nil)
        
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error, "test Timed Out")
        }
            XCTAssertTrue(successFlag)
   }
    
    func testErrorResponse() {
        let asyncExpectation = expectation(description: "ApiCall")
        var errorFlag = false
        self.testObject = RFRestFetcher(resource: "",
                                      method: RFMethod.get,
                                      headers: [String: String](),
                                      body: "",
                                      successCallback: { _ in
                XCTFail("Should not have been called")
            },
                                      errorCallback: { error in
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as? String))
                errorFlag = true
                asyncExpectation.fulfill()
            })
        
        guard let url = URL(string: "https://google.com") else {
            XCTFail("no url")
            return
        }
        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [String: String]())
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        self.testObject?.urlSessionComplete(data: data,
                                            response: mockResponse,
                                            error: NSError(domain: "", code: -1, userInfo: nil))
        
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error, "test Timed Out")
        }
        XCTAssertTrue(errorFlag)
    }
    
    func testNonNSHTTPURLResponse() {
        testObject = RFRestFetcher(resource: "",
                                 method: RFMethod.get,
                                 headers: [String: String](),
                                 body: "",
                                 successCallback: { _ in
                XCTFail("Should not have been called")
            },
                                 errorCallback: { error in
                XCTAssertEqual(error.code, 999)
                XCTAssertEqual("Network Error", (error.userInfo["message"] as? String))
        })
        let mockResponse = URLResponse()
        let data = "{\"thing\":\"one\"}".data(using: String.Encoding.utf8)
        testObject?.urlSessionComplete(data: data, response: mockResponse, error: NSError(domain: "", code: -1, userInfo: nil))
    }
    // swiftlint:disable nesting
    func testFetch() {
        class MockTask: URLSessionDataTask {
            var resumeCalled = false
            fileprivate override func resume() {
                resumeCalled = true
            }
        }
        class MockSession: URLSession {
            let headers: [String: String] = ["header1": "one", "header2": "two"]
            var dataTaskCalled = false
            var urlRequest: URLRequest?
            var mockTaskObject = MockTask()
            fileprivate override func dataTask(with request: URLRequest,
                                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                urlRequest = request
                dataTaskCalled = true
                guard let bodyData = request.httpBody,
                    let body = NSString(data: bodyData, encoding: String.Encoding.utf8.rawValue) else {
                    XCTFail("No Body")
                    return mockTaskObject
                }
                XCTAssertEqual("{\"thing\":\"one\", \"otherThing\":\"two\"}", body)
                XCTAssertEqual("POST", request.httpMethod)
                for (key, value) in request.allHTTPHeaderFields ?? [:] {
                    XCTAssertEqual(headers[key], value)
                }
                return mockTaskObject
            }
        }
        let mockSessionObject = MockSession()
        testObject?.setUrlSession(session: mockSessionObject)
        testObject?.fetch()
        
        XCTAssertTrue(mockSessionObject.dataTaskCalled)
        XCTAssertTrue(mockSessionObject.mockTaskObject.resumeCalled)
    }
    
}
