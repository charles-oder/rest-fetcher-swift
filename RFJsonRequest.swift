//
//  JsonRequest.swift
//  Pods-RestFetcherExample
//
//  Created by Charles Oder DTN on 1/27/18.
//

import Foundation

open class RFJsonRequest<T: Decodable>: RFRequest<T> {
    
    open var jsonRequestObject: Encodable? {
        return nil
    }
    
    open override var requestBody: String {
        return jsonRequestObject?.jsonString ?? super.requestBody
    }
    
    open override var requestHeaders: [String: String] {
        var headers = super.requestHeaders
        headers["Accept"] = "application/json"
        if jsonRequestObject != nil {
            headers["Content-Type"] = "application/json"
        }
        return headers
    }
    
    open override func createResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) -> T? {
        guard let unwrappedData = data else {
            return nil
        }
        
        if T.self == RFDataResponse.self {
            return RFDataResponse(data: data) as? T
        }
        
        guard let jsonString = String(data: unwrappedData, encoding: .utf8) else {
            return nil
        }
        
        return createResponseFromJsonString(code: code, headers: headers, jsonString: jsonString)
    }

    open func createResponseFromJsonString(code: Int, headers: [String: String], jsonString: String) -> T? {
        return T(jsonString: jsonString)
    }

}

public struct RFVoidResponse: Decodable {
    
}

public struct RFDataResponse: Decodable {
    public var data: Data?
}

public extension Decodable {
    
    public init?(jsonString: String) {
        
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        guard let decoded = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        
        self = decoded
    }

}

public extension Encodable {
    
    var jsonString: String? {
        guard let encodedData = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return String(data: encodedData, encoding: .utf8)
    }
}
