import Foundation

@objc
public class RFResponse: NSObject {
    public let headers: [String: String]
    public let code: Int
    public let data: Data?
    public let responseTime: Double
    
    public init(headers: [String: String], code: Int, data: Data?, responseTime: Double) {
        self.headers = headers
        self.code = code
        self.data = data
        self.responseTime = responseTime
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

public extension RFResponse {
    public var body: String? {
        guard let unwrappedData = data else {
            return nil
        }
        return String(data: unwrappedData, encoding: .utf8)
    }
    
}
