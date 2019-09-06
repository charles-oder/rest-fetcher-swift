import XCTest
@testable import RestFetcher

class RFRequestTests: XCTestCase {
    
    var testRequest: ConcreteRestRequest?
    var mockResponse = RFResponse(headers: [String: String](), code: 200, data: Data(), responseTime: 1.0)
    var mockFetcher: RFRestFetcher?
    
    override func setUp() {
        super.setUp()
        testRequest = ConcreteRestRequest()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRestMethod() {
        let expectedRestMethod = RFMethod.get
        let actualRestMethod = testRequest?.restMethod
        XCTAssertEqual(actualRestMethod, expectedRestMethod)
    }
    
    func testBuildUrlString() {
        guard let actuaResource = testRequest?.requestUrlString else {
            XCTFail("actuaResource is nil")
            return
        }
        XCTAssertTrue(actuaResource.contains("http://google.com/api?"))
        XCTAssertTrue(actuaResource.contains("arg2=value2"))
        XCTAssertTrue(actuaResource.contains("arg1=value%201"))
    }
    
    func testBody() {
        let expectedBody = ""
        let actualBody = testRequest?.requestBody
        XCTAssertEqual(actualBody, expectedBody)
    }
    
    // swiftlint:disable nesting
    func testFilledBodyDict() {
        class MockRequest: ConcreteRestRequest {
            
            fileprivate override var requestBodyDictionary: [String: Any?] {
                var expectedDict = [String: Any?]()
                expectedDict["key1"] = "value1"
                return expectedDict
            }
        }
        testRequest = MockRequest()
        var expectedDict = [String: Any?]()
        expectedDict["key1"] = "value1"
        XCTAssertEqual(expectedDict.count, 1)
        XCTAssertEqual("{\"key1\":\"value1\"}", testRequest?.requestBody)
    }
    
    func testEmptyBodyDict() {
        let expectedDict = [String: Any?]()
        XCTAssertEqual(expectedDict.count, 0)
    }
    
    func testHeaders() {
        let expectedSize = 2
        let headers = testRequest?.requestHeaders
        let actualSize = headers?.count
        XCTAssertEqual(actualSize, expectedSize)
        XCTAssertEqual(headers?["Accept"], "application/json; version=1")
        XCTAssertEqual(headers?["Content-Type"], "application/json; charset=utf-8")
    }
    
    func testSuccessCallback() {
        var success = false
        testRequest = ConcreteRestRequest()
        testRequest?.successCallback = {code, response in
            success = true
            XCTAssertEqual(code, 200)
        }
        testRequest?.errorCallback = { _ in
            XCTFail("Sould not be here")
        }
        testRequest?.restFetcherSuccess(response: mockResponse)
        XCTAssert(success)
    }
    
    func testErrorCallback() {
        var success = false
        testRequest = ConcreteRestRequest()
        testRequest?.successCallback = {code, response in
            XCTFail("Sould not be here")
        }
        testRequest?.errorCallback = { error in
            success = true
            let actualCode = error.code
            let actualReason = error.userInfo["message"] as? String
            XCTAssertEqual(actualCode, 400)
            XCTAssertEqual(actualReason, "Some Error")
        }
        testRequest?.restFetcherError(error: NSError(domain: "RestFetcher", code: 400, userInfo: ["message": "Some Error"]))
        XCTAssert(success)
    }
    
    func testCancelCall() {
        testRequest = ConcreteRestRequest()
        testRequest?.successCallback = {code, response in
            XCTFail("Sould not be here")
        }
        testRequest?.errorCallback = { _ in
            XCTFail("Sould not be here")
        }
        testRequest?.cancel()
        testRequest?.restFetcherSuccess(response: mockResponse)
        testRequest?.restFetcherError(error: NSError(domain: "RestFetcher", code: 400, userInfo: ["message": "Some Error"]))
    }
    
    // swiftlint:disable nesting
    func testFetch() {
        class MockFetcher: RFRestFetcher {
            var fetched = false
            init() {
                super.init(resource: "",
                           method: RFMethod.get,
                           headers: [String: String](),
                           body: "",
                           logger: RFConsoleLogger(),
                           timeout: 30,
                           successCallback: { _ in },
                           errorCallback: { _ in })
            }
            override func fetch() {
                fetched = true
            }
        }
        class MockFetcherBuilder: RestFetcherBuilder {
            var mockFetcher = MockFetcher()
            
            // swiftlint:disable function_parameter_count
            fileprivate func createRestFetcher(resource: String,
                                               method: RFMethod,
                                               headers: [String: String],
                                               body: String,
                                               logger: RFLogger,
                                               timeout: TimeInterval,
                                               successCallback: @escaping (RFResponse) -> Void,
                                               errorCallback: @escaping (NSError) -> Void) -> RFRestFetcher {
                return mockFetcher
            }
        }
        let mockFetcherBuilder = MockFetcherBuilder()
        testRequest?.restFetcherBuilder = mockFetcherBuilder
        testRequest?.fetch()
        XCTAssert(mockFetcherBuilder.mockFetcher.fetched)
    }
    
    func testQueryArgumentsAreAtTheEndOfSubclasses() {
        let testObject = ConcreteRestRequest2()

        XCTAssertTrue(testObject.requestUrlString.contains("http://google.com/api/stuff?"))
        XCTAssertTrue(testObject.requestUrlString.contains("arg2=value2"))
        XCTAssertTrue(testObject.requestUrlString.contains("arg1=value%201"))
    }
    
    func testQueryArgumentsEncodeAmersands() {
        class TestRequest: ConcreteRestRequest {
            override var queryArguments: [String: String] {
                return ["arg": "M & Ms"]
            }
        }
        let testObject = TestRequest()
        let expectedResource = "http://google.com/api?arg=M%20%26%20Ms"
        
        XCTAssertEqual(expectedResource, testObject.requestUrlString)
    }

    func testWillCreateResponse() {
        class TestRequest: RFRequest<RFRawResponse<RFResponse>> {
            var callCount = 0
            override func willCreateResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) {
                callCount += 1
            }

            override func createResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) -> RFResponse? {
                return RFResponse(headers: headers, code: 200, data: nil, responseTime: 1.0)
            }
        }
        
        let testObject = TestRequest()
        XCTAssertEqual(0, testObject.callCount)

        testObject.prepare()
        XCTAssertEqual(0, testObject.callCount)

        testObject.fetch()
        XCTAssertEqual(0, testObject.callCount)

        guard let response = testObject.createResponse(responseTime: 1.0, code: 200, headers: [:], data: nil) else {
            XCTFail("response is nil")
            return
        }
        testObject.restFetcherSuccess(response: response)
        XCTAssertEqual(1, testObject.callCount)

    }

    func testWillFetchRequest() {
        class TestRequest: ConcreteRestRequest {
            var callCount = 0
            override func willFetchRequest(resource: String, method: RFMethod, headers: [String: String], body: String) {
                callCount += 1
            }
        }
        let testObject = TestRequest()
        XCTAssertEqual(0, testObject.callCount)

        testObject.prepare()
        XCTAssertEqual(0, testObject.callCount)

        testObject.fetch()
        XCTAssertEqual(1, testObject.callCount)

        _ = ((try? testObject.createResponse(responseTime: 0.5, code: 200, headers: [:], data: nil)) as RFVoidResponse.ResponseType??)
        XCTAssertEqual(1, testObject.callCount)

    }

}

open class ConcreteRestRequest2: ConcreteRestRequest {
    open override var pathResource: String {
        return "/stuff"
    }
    
}

open class ConcreteRestRequest: RFRequest<RFVoidResponse> {

    open override var domain: String {
        return "http://google.com"
    }
    
    open override var rootPath: String {
        return "/api"
    }
    
    open override var requestHeaders: [String: String] {
        var headers = super.requestHeaders
        headers["Accept"] = "application/json; version=1"
        headers["Content-Type"] = "application/json; charset=utf-8"
        return headers
    }
    
    open override var queryArguments: [String: String] {
        var args = super.queryArguments
        args["arg1"] = "value 1"
        args["arg2"] = "value2"
        return args
    }
}
