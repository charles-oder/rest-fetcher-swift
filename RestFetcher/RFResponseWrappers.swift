//
//  JsonRequest.swift
//  Pods-RestFetcherExample
//
//  Created by Charles Oder DTN on 1/27/18.
//

import Foundation

public protocol RFDecodable {
    associatedtype ResponseType
    
    static var acceptType: String? { get }
    
    var object: ResponseType? { get }

    init?(data: Data?)
}

public struct RFVoidResponse: RFDecodable {
    public typealias ResponseType = Void
    
    public static var acceptType: String? {
        return nil
    }
    
    public var object: ResponseType?
    
    public init?(data: Data?) {}
}

public struct RFDataResponse: RFDecodable {
    public typealias ResponseType = Data
    
    public static var acceptType: String? {
        return nil
    }
    
    public var object: ResponseType?
    
    public init?(data: Data?) {
        object = data
    }
}

public struct RFStringResponse: RFDecodable {
    public typealias ResponseType = String
    
    public static var acceptType: String? {
        return nil
    }
    
    public var object: ResponseType?
    
    public init?(data: Data?) {
        object = data?.toString
    }
}

public struct RFDecodableResponse<T: Decodable>: RFDecodable {
    public typealias ResponseType = T
    
    public static var acceptType: String? {
        return "application/json"
    }
    
    public var object: ResponseType?
    
    public init?(data: Data?) {
        object = T(data: data)
    }
}

public struct RFRawResponse<T>: RFDecodable {
    public typealias ResponseType = T
    
    public static var acceptType: String? {
        return nil
    }
    
    public var object: ResponseType?
    
    public init?(data: Data?) {}
}

extension Decodable {
    
    public init?(data: Data?) {
        
        guard let decoded = data?.decodeJson(Self.self) else {
            return nil
        }
        
        self = decoded
    }

}

extension Data {
    func decodeJson<T>(_ type: T.Type) -> T? where T: Decodable {
        return try? JSONDecoder().decode(T.self, from: self)
    }
}

extension Data {
    var toString: String? {
        return String(data: self, encoding: .utf8)
    }
}

extension JSONDecoder {
    func decode<T>(_ type: T.Type, fromOptional optionalData: Data?) throws -> T where T: Decodable {
        guard let data = optionalData else {
            throw NSError(domain: "JSON Decoding", code: 1, userInfo: ["message": "data is nil"])
        }
        let object: T = try decode(T.self, from: data)
        return object
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
