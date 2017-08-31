import Foundation

@objc
public class RestResponse: NSObject {
    public let headers: [String: String]
    public let code: RestResponseCode
    public let data: Data?
    
    public init(headers: [String: String], code: RestResponseCode, data: Data?) {
        self.headers = headers
        self.code = code
        self.data = data
    }
    
    public class func dataToString(_ data: Data?) -> String {
        var output = ""
        if let d = data {
            if let str = String(data: d, encoding: .utf8) {
                output = str as String
            }
        }
        return output
    }
    
}

public extension RestResponse {
    public var body: String? {
        guard let unwrappedData = data else {
            return nil
        }
        return String(data: unwrappedData, encoding: .utf8)
    }
    
}
