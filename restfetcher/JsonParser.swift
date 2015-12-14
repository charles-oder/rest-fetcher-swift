import UIKit
import SwiftyJSON

public class JsonParser {
    
    public static func createJsonFromString(jsonString: String) -> JSON {
        return JSON(data: jsonString.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public static func toJsonString(json: JSON) -> String {
        if let str = json.rawString(NSUTF8StringEncoding, options:NSJSONWritingOptions(rawValue: 0)) {
            return str
        } else {
            return ""
        }
    }
}
