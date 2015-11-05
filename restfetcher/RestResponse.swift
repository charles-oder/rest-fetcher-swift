import Foundation
import SwiftyJSON

public class RestResponse : AnyObject {
    public let headers : Dictionary<String, String>!
    public let code : RestResponseCode
    public let body : String!
    public let json : JSON!
    public let jsonParseError : NSError?
    
    public init(headers: Dictionary<String, String>, code: RestResponseCode, body: String) {
        self.headers = headers
        self.code = code
        self.body = body
        var error : NSError?
        var json : JSON?
        if let data = body.dataUsingEncoding(NSUTF8StringEncoding) {
            json = JSON(data:data, options:NSJSONReadingOptions.AllowFragments, error:&error)
        }
        self.json = json
        jsonParseError = error
    }
    
}
