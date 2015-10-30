import Foundation

public class RestError : AnyObject {
    
    public let code : Int!
    public let reason : String!
    
    init(code: Int, reason : String) {
        self.code = code
        self.reason = reason
    }
}