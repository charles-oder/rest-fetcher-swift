import XCTest

class SensiApiBaseTests: XCTestCase {

    var testReuest : ConcreteApiBaseRequest!
    var mockResponse = RestResponse(headers: Dictionary<String,String>(), code: RestResponseCode.OK, body: "")
    var mockFetcher : RestFetcher?
    
    override func setUp() {
        super.setUp()
        testReuest = ConcreteApiBaseRequest(successCallback: {(response:RestApiBaseResponse) in}, errorCallback:{(error:RestError)in})
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testRestMethod() {
        let expectedRestMethod = RestMethod.GET
        let actualRestMethod = testReuest!.getRestMethod()
        XCTAssertEqual(actualRestMethod, expectedRestMethod)
    }
    
    func testApiResource() {
        let expectedResource = "http://google.com/api?arg2=value2&arg1=value%201"
        let actuaResource = testReuest!.getApiResource()
        XCTAssertEqual(actuaResource, expectedResource)
    }
    
    func testBody() {
        let expectedBody = ""
        let actualBody = testReuest!.getBody()
        XCTAssertEqual(actualBody, expectedBody)
    }
    
    func testFilledBodyDict() {
        class MockRequest : ConcreteApiBaseRequest {
            
            override init(successCallback: (response: RestApiBaseResponse) -> (), errorCallback: (error: RestError) -> ()) {
                super.init(successCallback: successCallback, errorCallback: errorCallback)
            }
            
            private override func getBodyDict() -> Dictionary<String, AnyObject> {
                var expectedDict = Dictionary<String, AnyObject>()
                expectedDict["key1"] = "value1"
                return expectedDict
            }
        }
        testReuest = MockRequest(successCallback: {(response:RestApiBaseResponse) in}, errorCallback:{(error:RestError)in})
        var expectedDict = Dictionary<String, AnyObject>()
        expectedDict["key1"] = "value1"
        XCTAssertEqual(expectedDict.count, 1)
        XCTAssertEqual("{\"key1\":\"value1\"}", testReuest?.getBody())
    }
    
    func testEmptyBodyDict() {
        let expectedDict = Dictionary<String, AnyObject>()
        XCTAssertEqual(expectedDict.count, 0)
    }
    
    func testHeaders() {
        let expectedSize = 2
        let headers = testReuest!.getHeaders()
        let actualSize = headers.count
        XCTAssertEqual(actualSize, expectedSize)
        XCTAssertEqual(headers["Accept"]!, "application/json; version=1")
        XCTAssertEqual(headers["Content-Type"]!, "application/json; charset=utf-8")
    }
    
    func testSuccessCallback() {
        var success = false
        testReuest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
            success = true
            let actualCode = response.code
            XCTAssertEqual(actualCode, RestResponseCode.OK)
            }, errorCallback:{(error:RestError) in
                XCTFail("Sould not be here")
        })
        testReuest!.restFetcherSuccess(mockResponse)
        XCTAssert(success)
    }
    
    func testErrorCallback() {
        var success = false
        testReuest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
                XCTFail("Sould not be here")
            }, errorCallback:{(error:RestError) in
                success = true
                let actualCode = error.code
                let actualReason = error.reason
                XCTAssertEqual(actualCode, 400)
                XCTAssertEqual(actualReason, "Some Error")
        })
        testReuest!.restFetcherError(RestError(code: 400, reason: "Some Error"))
        XCTAssert(success)
    }
    
    func testCancelCall() {
        testReuest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
            XCTFail("Sould not be here")
            }, errorCallback:{(error:RestError) in
                XCTFail("Sould not be here")
        })
        testReuest!.cancel()
        testReuest!.restFetcherSuccess(mockResponse)
        testReuest!.restFetcherError(RestError(code: 400, reason: "Some Error"))
    }
    
    func testFetch() {
        class MockFetcher : RestFetcher {
            var fetched = false
            init(){
                super.init(resource: "", method: RestMethod.GET, headers: Dictionary<String,String>(), body: "", successCallback: {(response:RestResponse)in}, errorCallback: {(error:RestError)in})
            }
            override func fetch() {
                fetched = true
            }
        }
        class MockFetcherBuilder : RestFetcherBuilder {
            var mockFetcher = MockFetcher()
            private func createRestFetcher(resource: String, method: RestMethod, headers: Dictionary<String, String>, body: String, successCallback: (response: RestResponse) -> (), errorCallback: (error: RestError) -> ()) -> RestFetcher {
                return mockFetcher
            }
        }
        let mockFetcherBuilder = MockFetcherBuilder()
        testReuest!.restFetcherBuilder = mockFetcherBuilder
        testReuest!.fetch()
        XCTAssert(mockFetcherBuilder.mockFetcher.fetched)
    }
    
    func testResponseWithNonJsonBody() {
        let mockResponseBody = "<HTML><body></body></HTML>"
        let mockResponse = RestResponse(headers: Dictionary<String, String>(), code: RestResponseCode.OK, body: mockResponseBody)
        let baseResponse = RestApiBaseResponse(response: mockResponse)
        let error = baseResponse.response.jsonParseError
        XCTAssertNotNil(error)
    }
    

}

public class ConcreteApiBaseRequest : RestApiBaseRequest<RestApiBaseResponse> {
    
    public override init(successCallback: (response: RestApiBaseResponse) -> (), errorCallback: (error: RestError) -> ()) {
        super.init(successCallback: successCallback, errorCallback: errorCallback)
    }
    
    public override func getApiBase() -> String {
        return "http://google.com"
    }
    
    public override func getApiRoot() -> String {
        return "/api"
    }
    
    public override func getQueryArguments() -> Dictionary<String, String> {
        var args = super.getQueryArguments()
        args["arg1"] = "value 1"
        args["arg2"] = "value2"
        return args
    }
}
