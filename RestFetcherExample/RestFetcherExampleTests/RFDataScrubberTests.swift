//
//  RFDataScrubberTests.swift
//  RestFetcherExampleTests
//
//  Created by Charles Oder DTN on 1/27/18.
//

import XCTest
import RestFetcher

class RFDataScrubberTests: XCTestCase {
    
    func testScrubJsonKeyThatMatchesExactly() {
        let json = "{\"password\":\"monkey\"}"
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = ((try? testObject.scrub(json: json)) as String??) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result?.contains("monkey"))
    }
    
    func testScrubJsonKeyThatContainsKey() {
        let json = "{\"thePasswordthing\":\"monkey\"}"
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = ((try? testObject.scrub(json: json)) as String??) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result?.contains("monkey"))
    }
    
    func testScrubJsonKeyThatContainsKeyWithWhitespace() {
        let json = "{\"thePassword\" : \"monkey\"}"
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = ((try? testObject.scrub(json: json)) as String??) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result?.contains("monkey"))
    }
    
    func testScrubJsonKeyWithEmptyValue() {
        let json = "{\"thePassword\":\"\"}"
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = ((try? testObject.scrub(json: json)) as String??) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result?.contains("monkey"))
    }

    func testLeavesOtherFieldsAlone() {
        let json = "{\"dateTime\":\"8675309\"}"
        
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = ((try? testObject.scrub(json: json)) as String??) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(true, result?.contains("8675309"))

    }
}
