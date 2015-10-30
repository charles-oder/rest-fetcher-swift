import Foundation

public enum RestResponseCode : Int {
    
    case NOT_FOUND = 404
    case OK = 200
    case NO_CONTENT = 204
    case BAD_REQUEST = 400
    case UNAUTHORIZED = 401
    case FORBIDDEN = 403
    case CONFLICT = 409
    case INTERNAL_SERVER_ERROR = 500
    case METHOD_NOT_ALLOWED = 405
    case UNKNOWN = 999
    case REQUEST_TIMEOUT = 408
    
    static func getResponseCode(code: Int) -> RestResponseCode {
        if let c = RestResponseCode(rawValue: code) {
            return c
        } else {
            return RestResponseCode.UNKNOWN
        }
    }
    
    var description : String {
        
        get {
            switch(self) {
            case .NOT_FOUND:
                return "NOT FOUND"
            case .OK:
                return "OK"
            case .NO_CONTENT:
                return "NO CONTENT"
            case .BAD_REQUEST:
                return "BAD REQUEST"
            case .UNAUTHORIZED:
                return "UNAUTHORIZED"
            case .FORBIDDEN:
                return "FORBIDDEN"
            case .CONFLICT:
                return "CONFLICT"
            case .INTERNAL_SERVER_ERROR:
                return "INTERNAL SERVER ERROR"
            case .METHOD_NOT_ALLOWED:
                return "METHOD NOT ALLOWED"
            case .REQUEST_TIMEOUT:
                return "REQUEST TIMEOUT"
            case .UNKNOWN:
                return "UNKNOWN"
            }
        }
    }
}
