import Foundation
import SwiftyJSON

public class RestResponse : AnyObject {
    let headers : Dictionary<String, String>!
    let code : RestResponseCode!
    let body : String!
    let json : JSON!
    let jsonParseError : NSError?
    
    init(headers: Dictionary<String, String>, code: RestResponseCode, body: String) {
        self.headers = headers
        self.code = code
        self.body = body
        var error : NSError?
        if let data = body.dataUsingEncoding(NSUTF8StringEncoding) {
            json = JSON(data:data, options:NSJSONReadingOptions.AllowFragments, error:&error)
        } else {
            json = JSON([])
            error = NSError(domain: "Sensi", code: 999, userInfo:["NSDebugDescritpion":"Non-String Response Data"])
        }
        jsonParseError = error
    }
}