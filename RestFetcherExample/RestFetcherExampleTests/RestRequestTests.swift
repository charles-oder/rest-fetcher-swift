import XCTest
@testable import RestFetcher

class RestRequestTests: XCTestCase {
    
    var testRequest: ConcreteRestRequest?
    var mockResponse = RestResponse(headers: [String: String](), code: RestResponseCode.ok, data: Data())
    var mockFetcher: RestFetcher?
    
    override func setUp() {
        super.setUp()
        testRequest = ConcreteRestRequest()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRestMethod() {
        let expectedRestMethod = RestMethod.get
        let actualRestMethod = testRequest?.restMethod
        XCTAssertEqual(actualRestMethod, expectedRestMethod)
    }
    
    func testBuildUrlString() {
        let expectedResource = "http://google.com/api?arg2=value2&arg1=value%201"
        let actuaResource = testRequest?.requestUrlString
        XCTAssertEqual(actuaResource, expectedResource)
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
            XCTAssertEqual(code, RestResponseCode.ok)
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
        class MockFetcher: RestFetcher {
            var fetched = false
            init() {
                super.init(resource: "",
                           method: RestMethod.get,
                           headers: [String: String](),
                           body: "",
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
                                               method: RestMethod,
                                               headers: [String: String],
                                               body: String,
                                               successCallback: @escaping (RestResponse) -> Void,
                                               errorCallback: @escaping (NSError) -> Void) -> RestFetcher {
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
        let expectedResource = "http://google.com/api/stuff?arg2=value2&arg1=value%201"
        
        XCTAssertEqual(expectedResource, testObject.requestUrlString)
    }
    
    
//    // Revisit this if Swift devs ever respond to issue https://bugs.swift.org/browse/SR-5809
//    func testDecodable() {
//        class Thing: Decodable {
//            var monkey: String
//        }
//
//        class TestRequest: RestRequest<Thing> {
//
//        }
//
//        let jsonString = """
//                {"monkey":"shines"}
//        """
//        let data = jsonString.data(using: .utf8)
//
//        let response = TestRequest().createResponse(code: 200, headers: [:], data: data)
//
//        XCTAssertEqual("shines", response?.monkey)
//    }
//
//    func testDecodableArray() {
//        class Thing: Decodable {
//            var monkey: String
//        }
//
//        class TestRequest: RestRequest<[Thing]> {
//
//        }
//
//        let jsonString = """
//                [{"monkey":"shines"},{"monkey":"sees"}]
//        """
//        let data = jsonString.data(using: .utf8)
//
//        let response = TestRequest().createResponse(code: 200, headers: [:], data: data)
//
//        XCTAssertEqual(2, response?.count)
//        XCTAssertEqual("shines", response?.first?.monkey)
//        XCTAssertEqual("sees", response?.last?.monkey)
//    }
//
//    func testStringRequest() {
//        let string = "this is a test string"
//        let data = string.data(using: .utf8)
//
//        class TestRequest: RestRequest<String> {
//
//        }
//
//        let response = TestRequest().createResponse(code: 200, headers: [:], data: data)
//
//        XCTAssertEqual(string, response)
//
//    }
//
//    func testDataRequest() {
//        let string = "this is a test string"
//        let data = string.data(using: .utf8)
//
//        class TestRequest: RestRequest<Data> {
//
//        }
//
//        let response = TestRequest().createResponse(code: 200, headers: [:], data: data)
//
//        XCTAssertEqual(data, response)
//
//    }
}

open class ConcreteRestRequest2: ConcreteRestRequest {
    open override var pathResource: String {
        return "/stuff"
    }
    
}

open class ConcreteRestRequest: RestRequest<ConcreteRestResponse> {

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

extension RestRequest where T == ConcreteRestResponse {
    func createResponse(code: Int, headers: [String: String], data: Data?) -> T? {
        return ConcreteRestResponse()
    }
}

open class ConcreteRestResponse {
}
