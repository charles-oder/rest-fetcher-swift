//
//  RFDataScrubberTests.swift
//  RestFetcherExampleTests
//
//  Created by Charles Oder DTN on 1/27/18.
//

import XCTest
import RestFetcher

class RFDataScrubberTests: XCTestCase {
    
    func testScrubJson() {
        let json = "{\"password\":\"monkey\"}"
        let testObject = RFDataScrubber(keysToScrub: ["password"])
        
        guard let result = testObject.scrub(json: json) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result.contains("monkey"))
    }
    
    func testScrubDictionary() {
        let dictionary: [String: Any] = ["credentials": "banana"]
        let testObject = RFDataScrubber(keysToScrub: ["credentials"])
        
        let result = testObject.scrub(dictionary: dictionary)
        
        XCTAssertNotNil(result["credentials"] as? String)
        XCTAssertNotEqual("banana", result["credentials"] as? String)

    }
    
}
