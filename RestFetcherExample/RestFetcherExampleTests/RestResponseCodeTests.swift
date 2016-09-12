//
//  RestResponseCodeTests.swift
//  RestFetcher
//
//  Created by Charles Oder on 10/14/15.
//  Copyright © 2015 Charles Oder. All rights reserved.
//

import XCTest
@testable import RestFetcher

class RestResponseCodeTests: XCTestCase {
    
    func testUnknown() {
        let testObject = RestResponseCode.UNKNOWN
        
        XCTAssertEqual("UNKNOWN", testObject.description)
        XCTAssertEqual(999, testObject.rawValue)
    }
    
    func testOk() {
        let testObject = RestResponseCode.OK
        
        XCTAssertEqual("OK", testObject.description)
        XCTAssertEqual(200, testObject.rawValue)
    }
    
    func testNotFound() {
        let testObject = RestResponseCode.NOT_FOUND
        
        XCTAssertEqual("NOT FOUND", testObject.description)
        XCTAssertEqual(404, testObject.rawValue)
    }
    
    func testNoContent() {
        let testObject = RestResponseCode.NO_CONTENT
        
        XCTAssertEqual("NO CONTENT", testObject.description)
        XCTAssertEqual(204, testObject.rawValue)
    }
    
    func testBadRequest() {
        let testObject = RestResponseCode.BAD_REQUEST
        
        XCTAssertEqual("BAD REQUEST", testObject.description)
        XCTAssertEqual(400, testObject.rawValue)
    }
    
    func testForbidden() {
        let testObject = RestResponseCode.FORBIDDEN
        
        XCTAssertEqual("FORBIDDEN", testObject.description)
        XCTAssertEqual(403, testObject.rawValue)
    }
    
    func testUnauthorized() {
        let testObject = RestResponseCode.UNAUTHORIZED
        
        XCTAssertEqual("UNAUTHORIZED", testObject.description)
        XCTAssertEqual(401, testObject.rawValue)
    }
    
    func testConflict() {
        let testObject = RestResponseCode.CONFLICT
        
        XCTAssertEqual("CONFLICT", testObject.description)
        XCTAssertEqual(409, testObject.rawValue)
   }
    
    func testInternalServerError() {
        let testObject = RestResponseCode.INTERNAL_SERVER_ERROR
        
        XCTAssertEqual("INTERNAL SERVER ERROR", testObject.description)
        XCTAssertEqual(500, testObject.rawValue)
    }
    
    func testMethodNotAllowed() {
        let testObject = RestResponseCode.METHOD_NOT_ALLOWED
        
        XCTAssertEqual("METHOD NOT ALLOWED", testObject.description)
        XCTAssertEqual(405, testObject.rawValue)
    }
    
    func testRequestTimeout() {
        let testObject = RestResponseCode.REQUEST_TIMEOUT
        
        XCTAssertEqual("REQUEST TIMEOUT", testObject.description)
        XCTAssertEqual(408, testObject.rawValue)
    }
    
    func testKnownResponseCode() {
        let testObject = RestResponseCode.getResponseCode(200)
        
        XCTAssertEqual(RestResponseCode.OK, testObject)
    }
    
    func testUnknownResponseCode() {
        let testObject = RestResponseCode.getResponseCode(654)
        
        XCTAssertEqual(RestResponseCode.UNKNOWN, testObject)
    }
    
}
