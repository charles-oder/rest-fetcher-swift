import Foundation

public class RestError : AnyObject {
    
    let code : Int!
    let reason : String!
    
    init(code: Int, reason : String) {
        self.code = code
        self.reason = reason
    }
}