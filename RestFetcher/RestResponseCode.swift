import Foundation

@objc
public enum RestResponseCode : Int {
    
    case notFound = 404
    case ok = 200
    case noContent = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case conflict = 409
    case internalServerError = 500
    case methodNotAllowed = 405
    case unknown = 999
    case requestTimeout = 408
    
    static func getResponseCode(_ code: Int) -> RestResponseCode {
        if let c = RestResponseCode(rawValue: code) {
            return c
        } else {
            return RestResponseCode.unknown
        }
    }
    
    var description : String {
        
        get {
            switch(self) {
            case .notFound:
                return "NOT FOUND"
            case .ok:
                return "OK"
            case .noContent:
                return "NO CONTENT"
            case .badRequest:
                return "BAD REQUEST"
            case .unauthorized:
                return "UNAUTHORIZED"
            case .forbidden:
                return "FORBIDDEN"
            case .conflict:
                return "CONFLICT"
            case .internalServerError:
                return "INTERNAL SERVER ERROR"
            case .methodNotAllowed:
                return "METHOD NOT ALLOWED"
            case .requestTimeout:
                return "REQUEST TIMEOUT"
            case .unknown:
                return "UNKNOWN"
            }
        }
    }
}
