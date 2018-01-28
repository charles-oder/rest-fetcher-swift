//
//  RFJsonRequestTests.swift
//  RestFetcherExampleTests
//
//  Created by Charles Oder DTN on 1/27/18.
//

import XCTest
import RestFetcher

class RFJsonRequestTests: XCTestCase {
    
    func testCreateResponse() {
        let request = RFJsonRequest<TestResponse>()
        let json = "{\"thing\":\"one\"}"
        let data = json.data(using: .utf8)
        
        let response = request.createResponse(responseTime: 1.0, code: 200, headers: [:], data: data)
        
        XCTAssertEqual("one", response?.thing)
    }
    
    func testUseRequestObject() {
        
        let testObject = TestRequest()
        
        testObject.testValue = "banana"
        
        XCTAssertEqual("{\"monkey\":\"banana\"}", testObject.requestBody)
        
        testObject.testValue = "orange"
        
        XCTAssertEqual("{\"monkey\":\"orange\"}", testObject.requestBody)
        
    }
    
    func testAcceptHeader() {
        let testObject = RFJsonRequest<RFVoidResponse>()
        XCTAssertEqual("application/json", testObject.requestHeaders["Accept"])
    }
    
    func testContentHeaderForNilBodyObject() {
        let testObject = RFJsonRequest<RFVoidResponse>()
        XCTAssertNil(testObject.requestHeaders["Content-Type"])
    }
    
    func testContentHeaderForNonNilBodyObject() {
        let testObject = TestRequest()
        XCTAssertEqual("application/json", testObject.requestHeaders["Content-Type"])
    }
    
    func testDataResponse() {
        let testObject = RFJsonRequest<RFDataResponse>()
        let testData = "test".data(using: .utf8)
        
        guard let response = testObject.createResponse(responseTime: 1.0, code: 200, headers: [:], data: testData) else {
            XCTFail("Nil response")
            return
        }
        
        guard let actualData = response.data else {
            XCTFail("Nil data")
            return
        }
        
        XCTAssertEqual("test", String(data: actualData, encoding: .utf8))
    }
    
    struct TestResponse: Decodable {
        var thing: String?
    }
    
    struct TestEntity: Encodable {
        var monkey: String?
    }
    
    class TestRequest: RFJsonRequest<RFVoidResponse> {
        var testValue: String?
        override var jsonRequestObject: Encodable? {
            return TestEntity(monkey: testValue)
        }
    }
    
}
