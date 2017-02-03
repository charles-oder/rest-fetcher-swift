import XCTest
@testable import RestFetcher

class SensiApiBaseTests: XCTestCase {

    var testRequest: ConcreteApiBaseRequest?
    var mockResponse = RestResponse(headers: [String: String](), code: RestResponseCode.ok, data: Data())
    var mockFetcher: RestFetcher?
    
    override func setUp() {
        super.setUp()
        testRequest = ConcreteApiBaseRequest(successCallback: { _ in }, errorCallback: { _ in })
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testRestMethod() {
        let expectedRestMethod = RestMethod.get
        let actualRestMethod = testRequest?.getRestMethod()
        XCTAssertEqual(actualRestMethod, expectedRestMethod)
    }
    
    func testBuildUrlString() {
        let expectedResource = "http://google.com/api?arg2=value2&arg1=value%201"
        let actuaResource = testRequest?.buildUrlString()
        XCTAssertEqual(actuaResource, expectedResource)
    }
    
    func testBody() {
        let expectedBody = ""
        let actualBody = testRequest?.getBody()
        XCTAssertEqual(actualBody, expectedBody)
    }
    
    // swiftlint:disable nesting
    func testFilledBodyDict() {
        class MockRequest: ConcreteApiBaseRequest {
            
            override init(successCallback: @escaping (_ response: ConcreteApiBaseResponse) -> Void,
                          errorCallback: @escaping (_ error: NSError) -> Void) {
                super.init(successCallback: successCallback, errorCallback: errorCallback)
            }
            
            fileprivate override func getBodyDict() -> [String: AnyObject] {
                var expectedDict = [String: AnyObject]()
                expectedDict["key1"] = "value1" as AnyObject?
                return expectedDict
            }
        }
        testRequest = MockRequest(successCallback: { _ in }, errorCallback: { _ in })
        var expectedDict = [String: AnyObject]()
        expectedDict["key1"] = "value1" as AnyObject?
        XCTAssertEqual(expectedDict.count, 1)
        XCTAssertEqual("{\"key1\":\"value1\"}", testRequest?.getBody())
    }
    
    func testEmptyBodyDict() {
        let expectedDict = [String: AnyObject]()
        XCTAssertEqual(expectedDict.count, 0)
    }
    
    func testHeaders() {
        let expectedSize = 2
        let headers = testRequest?.getHeaders()
        let actualSize = headers?.count
        XCTAssertEqual(actualSize, expectedSize)
        XCTAssertEqual(headers?["Accept"], "application/json; version=1")
        XCTAssertEqual(headers?["Content-Type"], "application/json; charset=utf-8")
    }
    
    func testSuccessCallback() {
        var success = false
        testRequest = ConcreteApiBaseRequest(successCallback: { response in
            success = true
            let actualCode = response.code
            XCTAssertEqual(actualCode, RestResponseCode.ok)
            }, errorCallback: { _ in
                XCTFail("Sould not be here")
        })
        testRequest?.restFetcherSuccess(response: mockResponse)
        XCTAssert(success)
    }
    
    func testErrorCallback() {
        var success = false
        testRequest = ConcreteApiBaseRequest(successCallback: { _ in
                XCTFail("Sould not be here")
            }, errorCallback: { error in
                success = true
                let actualCode = error.code
                let actualReason = error.userInfo["message"] as? String
                XCTAssertEqual(actualCode, 400)
                XCTAssertEqual(actualReason, "Some Error")
        })
        testRequest?.restFetcherError(error: NSError(domain: "RestFetcher", code: 400, userInfo: ["message": "Some Error"]))
        XCTAssert(success)
    }
    
    func testCancelCall() {
        testRequest = ConcreteApiBaseRequest(successCallback: { _ in
            XCTFail("Sould not be here")
            }, errorCallback: { _ in
                XCTFail("Sould not be here")
        })
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
                           headers: [String: String](), body: "",
                           successCallback: { _ in },
                           errorCallback: { _ in })
            }
            override func fetch() {
                fetched = true
            }
        }
        // swiftlint:disable nesting
        // swiftlint:disable function_parameter_count
        class MockFetcherBuilder: RestFetcherBuilder {
            var mockFetcher = MockFetcher()
            
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
        let testObject = ConcreteApiBaseRequest2(successCallback: { _ in }, errorCallback: { _ in })
        let expectedResource = "http://google.com/api/stuff?arg2=value2&arg1=value%201"
        
        XCTAssertEqual(expectedResource, testObject.buildUrlString())
    }
    
}

open class ConcreteApiBaseRequest2: ConcreteApiBaseRequest {
    open override func getApiResource() -> String {
        return "\(super.getApiResource())/stuff"
    }
    
}

open class ConcreteApiBaseRequest: RestApiBaseRequest<ConcreteApiBaseResponse> {
    
    public override init(successCallback: @escaping (_ response: ConcreteApiBaseResponse) -> Void,
                         errorCallback: @escaping (_ error: NSError) -> Void) {
        super.init(successCallback: successCallback, errorCallback: errorCallback)
    }
    
    open override func getApiBase() -> String {
        return "http://google.com"
    }
    
    open override func getApiRoot() -> String {
        return "/api"
    }
    
    open override func createResponse(_ response: RestResponse) -> ConcreteApiBaseResponse {
        return ConcreteApiBaseResponse(response: response)
    }
    
    open override func getHeaders() -> [String: String] {
        var headers = super.getHeaders()
        headers["Accept"] = "application/json; version=1"
        headers["Content-Type"] = "application/json; charset=utf-8"
        return headers
    }
    
    open override func getQueryArguments() -> [String: String] {
        var args = super.getQueryArguments()
        args["arg1"] = "value 1"
        args["arg2"] = "value2"
        return args
    }
}

open class ConcreteApiBaseResponse: RestApiBaseResponse {
    public override init(response: RestResponse) {
        super.init(response: response)
    }
    
}
