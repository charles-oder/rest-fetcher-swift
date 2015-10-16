import Foundation
import SwiftyJSON

public class RestApiBase {
    
    public static var demoMode = false;
    
    public class Request {
        
        private var _cancel = false
        private var _restFetcher : RestFetcher?
        public var restFetcherBuilder : RestFetcherBuilder
        
        var successCallback : (response:RestApiBase.Response)->() = {(response: RestApiBase.Response)->()in}
        var errorCallback : (error:RestError)->() = {(error:RestError)->()in}
        
        convenience public init (successCallback:(response:RestApiBase.Response)->(), errorCallback:(error:RestError)->()) {
            self.init(restFetcherBuilder:RestFetcher.Builder(), successCallback:successCallback, errorCallback:errorCallback);
        }
        
        public init(restFetcherBuilder: RestFetcherBuilder, successCallback:(response:RestApiBase.Response)->(), errorCallback:(error:RestError)->()) {
            self.successCallback = successCallback
            self.errorCallback = errorCallback
            self.restFetcherBuilder = restFetcherBuilder
        }
        
        func getRestMethod() -> RestMethod {
            return RestMethod.GET
        }
        
        func getApiResource() -> String {
            return "http://google.com"
        }
        
        func getBody() -> String {
            let bodyDict = getBodyDict()
            if bodyDict.count == 0 {
                return ""
            }
            let bodyJson = JSON(bodyDict)
            if let output = bodyJson.rawString() {
                var value = output.stringByReplacingOccurrencesOfString("\n", withString: "")
                value = value.stringByReplacingOccurrencesOfString(" ", withString: "")
                return value
            }
            return "" // will never be hit in this code
        }
        
        func getBodyDict() -> Dictionary<String, AnyObject> {
            return Dictionary<String, AnyObject>()
        }

        
        func getHeaders() -> Dictionary<String, String> {
            var headers = Dictionary<String,String>()
            headers["Accept"] = "application/json; version=1"
            headers["Content-Type"] = "application/json; charset=utf-8"
            return headers
        }
        
        func createResponse(response:RestResponse) -> RestApiBase.Response {
            return RestApiBase.Response(response: response)
        }
        
        func restFetcherSuccess(response:RestResponse) {
            if !_cancel {
                successCallback(response: createResponse(response))
            }
        }
        
        func restFetcherError(error:RestError) {
            if !_cancel {
                errorCallback(error: error)
            }
        }
        
        func prepare() {
            _restFetcher = restFetcherBuilder.createRestFetcher(getApiResource(), method: getRestMethod(), headers: getHeaders(), body: getBody(), successCallback: restFetcherSuccess, errorCallback: restFetcherError)
        }
        
        func fetch() {
            if let fetcher = _restFetcher {
                fetcher.fetch()
            } else {
                prepare()
                fetch()
            }
        }
        
        func cancel() {
            _cancel = true
        }
    }
    
    public class Response {
        
        private var _code : RestResponseCode = RestResponseCode.UNKNOWN
        public let response : RestResponse!
        var code: RestResponseCode {
            get {
                return _code
            }
        }
        
        public init(response:RestResponse) {
            self.response = response
            processResponse(response)
        }
        
        internal func processResponse(response:RestResponse) {
            _code = response.code
        }
    }
}