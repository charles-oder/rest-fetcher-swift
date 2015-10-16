import Foundation
import SwiftyJSON

public class RestResponse : AnyObject {
    let headers : Dictionary<String, String>!
    let code : RestResponseCode
    let body : String!
    let json : JSON!
    let jsonParseError : NSError?
    
    init(headers: Dictionary<String, String>, code: RestResponseCode, body: String) {
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
