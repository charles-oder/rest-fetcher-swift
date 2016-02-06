import XCTest

class SensiApiBaseTests: XCTestCase {

    var testRequest : ConcreteApiBaseRequest!
    var mockResponse = RestResponse(headers: Dictionary<String,String>(), code: RestResponseCode.OK, data: NSData())
    var mockFetcher : RestFetcher?
    
    override func setUp() {
        super.setUp()
        testRequest = ConcreteApiBaseRequest(successCallback: {(response:RestApiBaseResponse) in}, errorCallback:{(error:NSError)in})
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testRestMethod() {
        let expectedRestMethod = RestMethod.GET
        let actualRestMethod = testRequest!.getRestMethod()
        XCTAssertEqual(actualRestMethod, expectedRestMethod)
    }
    
    func testBuildUrlString() {
        let expectedResource = "http://google.com/api?arg2=value2&arg1=value%201"
        let actuaResource = testRequest!.buildUrlString()
        XCTAssertEqual(actuaResource, expectedResource)
    }
    
    func testBody() {
        let expectedBody = ""
        let actualBody = testRequest!.getBody()
        XCTAssertEqual(actualBody, expectedBody)
    }
    
    func testFilledBodyDict() {
        class MockRequest : ConcreteApiBaseRequest {
            
            override init(successCallback: (response: ConcreteApiBaseResponse) -> (), errorCallback: (error: NSError) -> ()) {
                super.init(successCallback: successCallback, errorCallback: errorCallback)
            }
            
            private override func getBodyDict() -> Dictionary<String, AnyObject> {
                var expectedDict = Dictionary<String, AnyObject>()
                expectedDict["key1"] = "value1"
                return expectedDict
            }
        }
        testRequest = MockRequest(successCallback: {(response:RestApiBaseResponse) in}, errorCallback:{(error:NSError)in})
        var expectedDict = Dictionary<String, AnyObject>()
        expectedDict["key1"] = "value1"
        XCTAssertEqual(expectedDict.count, 1)
        XCTAssertEqual("{\"key1\":\"value1\"}", testRequest?.getBody())
    }
    
    func testEmptyBodyDict() {
        let expectedDict = Dictionary<String, AnyObject>()
        XCTAssertEqual(expectedDict.count, 0)
    }
    
    func testHeaders() {
        let expectedSize = 2
        let headers = testRequest!.getHeaders()
        let actualSize = headers.count
        XCTAssertEqual(actualSize, expectedSize)
        XCTAssertEqual(headers["Accept"]!, "application/json; version=1")
        XCTAssertEqual(headers["Content-Type"]!, "application/json; charset=utf-8")
    }
    
    func testSuccessCallback() {
        var success = false
        testRequest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
            success = true
            let actualCode = response.code
            XCTAssertTrue(self.testRequest === response.request)
            XCTAssertEqual(actualCode, RestResponseCode.OK)
            }, errorCallback:{(error:NSError) in
                XCTFail("Sould not be here")
        })
        testRequest!.restFetcherSuccess(mockResponse)
        XCTAssert(success)
    }
    
    func testErrorCallback() {
        var success = false
        testRequest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
                XCTFail("Sould not be here")
            }, errorCallback:{(error:NSError) in
                success = true
                let actualCode = error.code
                let actualReason = error.userInfo["message"] as! String
                XCTAssertEqual(actualCode, 400)
                XCTAssertEqual(actualReason, "Some Error")
        })
        testRequest!.restFetcherError(NSError(domain: "RestFetcher", code: 400, userInfo: ["message":"Some Error"]))
        XCTAssert(success)
    }
    
    func testCancelCall() {
        testRequest = ConcreteApiBaseRequest(successCallback:{(response:RestApiBaseResponse) in
            XCTFail("Sould not be here")
            }, errorCallback:{(error:NSError) in
                XCTFail("Sould not be here")
        })
        testRequest!.cancel()
        testRequest!.restFetcherSuccess(mockResponse)
        testRequest!.restFetcherError(NSError(domain: "RestFetcher", code: 400, userInfo: ["message":"Some Error"]))
    }
    
    func testFetch() {
        class MockFetcher : RestFetcher {
            var fetched = false
            init(){
                super.init(resource: "", method: RestMethod.GET, headers: Dictionary<String,String>(), body: "", successCallback: {(response:RestResponse)in}, errorCallback: {(error:NSError)in})
            }
            override func fetch() {
                fetched = true
            }
        }
        class MockFetcherBuilder : RestFetcherBuilder {
            var mockFetcher = MockFetcher()
            private func createRestFetcher(resource: String, method: RestMethod, headers: Dictionary<String, String>, body: String, successCallback: (response: RestResponse) -> (), errorCallback: (error: NSError) -> ()) -> RestFetcher {
                return mockFetcher
            }
        }
        let mockFetcherBuilder = MockFetcherBuilder()
        testRequest!.restFetcherBuilder = mockFetcherBuilder
        testRequest!.fetch()
        XCTAssert(mockFetcherBuilder.mockFetcher.fetched)
    }
    
    func testQueryArgumentsAreAtTheEndOfSubclasses() {
        let testObject = ConcreteApiBaseRequest2(successCallback: {_ in }, errorCallback: {_ in })
        let expectedResource = "http://google.com/api/stuff?arg2=value2&arg1=value%201"
        
        XCTAssertEqual(expectedResource, testObject.buildUrlString())
    }
    
}

public class ConcreteApiBaseRequest2 : ConcreteApiBaseRequest {
    public override func getApiResource() -> String {
        return "\(super.getApiResource())/stuff"
    }
    
}

public class ConcreteApiBaseRequest : RestApiBaseRequest<ConcreteApiBaseResponse> {
    
    public override init(successCallback: (response: ConcreteApiBaseResponse) -> (), errorCallback: (error: NSError) -> ()) {
        super.init(successCallback: successCallback, errorCallback: errorCallback)
    }
    
    public override func getApiBase() -> String {
        return "http://google.com"
    }
    
    public override func getApiRoot() -> String {
        return "/api"
    }
    
    public override func createResponse(response: RestResponse) -> ConcreteApiBaseResponse {
        return ConcreteApiBaseResponse(response: response)
    }
    
    public override func getHeaders() -> Dictionary<String, String> {
        var headers = super.getHeaders()
        headers["Accept"] = "application/json; version=1"
        headers["Content-Type"] = "application/json; charset=utf-8"
        return headers
    }
    
    public override func getQueryArguments() -> Dictionary<String, String> {
        var args = super.getQueryArguments()
        args["arg1"] = "value 1"
        args["arg2"] = "value2"
        return args
    }
}

public class ConcreteApiBaseResponse: RestApiBaseResponse {
    public override init(response: RestResponse) {
        super.init(response: response)
    }
    
    
}
