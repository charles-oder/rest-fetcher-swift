import Foundation

@objc
public class RestResponse : NSObject {
    public let headers : Dictionary<String, String>!
    public let code : RestResponseCode
    public let body : String!
    public let data : Data!
    
    public init(headers: Dictionary<String, String>, code: RestResponseCode, data: Data?) {
        self.headers = headers
        self.code = code
        self.body = RestResponse.dataToString(data)
        self.data = data
    }
    
    public class func dataToString(_ data:Data?) -> String {
        var output = ""
        if let d = data {
            if let str = NSString(data: d, encoding: String.Encoding.utf8.rawValue) {
                output = str as String
            }
        }
        return output
    }
    

}
