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
        
        guard let result = try? testObject.scrub(json: json) else {
            XCTFail("Error scrubbing json")
            return
        }
        
        XCTAssertEqual(false, result?.contains("monkey"))
    }
    
}
