import Foundation

@objc
public enum RestMethod: Int {
    case get = 1
    case post = 2
    case put = 3
    case delete = 4
    case patch = 5
    
    public func getString() -> String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .patch:
            return "PATCH"
        }
    }
}
