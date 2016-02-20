import Foundation

@objc
public enum RestMethod : Int {
    case GET = 1
    case POST = 2
    case PUT = 3
    case DELETE = 43
    
    public func getString() -> String {
        switch self
        {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .PUT:
            return "PUT"
        case .DELETE:
            return "DELETE"
        }
    }
}