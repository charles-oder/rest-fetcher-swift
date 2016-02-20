import Foundation

@objc
public class RestResponse : NSObject {
    public let headers : Dictionary<String, String>!
    public let code : RestResponseCode
    public let body : String!
    public let data : NSData!
    
    public init(headers: Dictionary<String, String>, code: RestResponseCode, data: NSData?) {
        self.headers = headers
        self.code = code
        self.body = RestResponse.dataToString(data)
        self.data = data
    }
    
    public class func dataToString(data:NSData?) -> String {
        var output = ""
        if let d = data {
            if let str = NSString(data: d, encoding: NSUTF8StringEncoding) {
                output = str as String
            }
        }
        return output
    }
    

}
