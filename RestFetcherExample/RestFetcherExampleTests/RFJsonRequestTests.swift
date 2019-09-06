//
//  RFJsonRequestTests.swift
//  RestFetcherExampleTests
//
//  Created by Charles Oder DTN on 1/27/18.
//

import XCTest
import RestFetcher

class RFJsonRequestTests: XCTestCase {
    
    func testCreateResponse() throws {
        let request = RFRequest<RFDecodableResponse<TestResponse>>()
        let json = "{\"thing\":\"one\"}"
        let data = json.data(using: .utf8)
        
        let response = try request.createResponse(responseTime: 1.0, code: 200, headers: [:], data: data)
        
        XCTAssertEqual("one", response?.thing)
    }
    
    func testAcceptHeader() {
        let testObject = RFRequest<RFDecodableResponse<TestResponse>>()
        XCTAssertEqual("application/json", testObject.requestHeaders["Accept"])
    }
    
    func testDataResponse() throws {
        let testObject = RFRequest<RFDataResponse>()
        let testData = "test".data(using: .utf8)
        
        guard let response = try testObject.createResponse(responseTime: 1.0, code: 200, headers: [:], data: testData) else {
            XCTFail("Nil response")
            return
        }
        
        XCTAssertEqual("test", String(data: response, encoding: .utf8))
    }
    
    func testStringResponse() {
        let testObject = RFRequest<RFStringResponse>()
        let testData = "test".data(using: .utf8)
        let response: RFStringResponse.ResponseType? = try? testObject.createResponse(responseTime: 1.0, code: 200, headers: [:], data: testData)
        guard response != nil else {
            XCTFail("Nil response")
            return
        }
        
        XCTAssertEqual("test", response)
    }
    
    struct TestResponse: Decodable {
        var thing: String?
    }
    
    struct TestEntity: Encodable {
        var monkey: String?
    }
    
}
