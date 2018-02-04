# RestFetcher

[![Build Status](https://travis-ci.org/charles-oder/rest-fetcher-swift.svg?branch=master)](https://travis-ci.org/charles-oder/rest-fetcher-swift)
[![Version](https://img.shields.io/cocoapods/v/RestFetcher.svg?style=flat)](http://cocoapods.org/pods/RestFetcher)
[![Swift](https://img.shields.io/badge/Swift-4-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-9-blue.svg)](https://developer.apple.com/xcode)
[![License](https://img.shields.io/cocoapods/l/RestFetcher.svg?style=flat)](http://cocoapods.org/pods/RestFetcher)
[![Platform](https://img.shields.io/cocoapods/p/RestFetcher.svg?style=flat)](http://cocoapods.org/pods/RestFetcher)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RestFetcher is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RestFetcher"
```
## Usage

# RFRequest
RFRequest<T: RFDecodable>
This is a base intended to be extended to support a family of REST requests. T defines the class of the response to be generated by each request.

You may customize each request and any child requests by overriding the following:

```swift
var logger: RFLogger
default = RFConsoleLogger
Allows child classes to inject their own logging framework with any object that conforms to the RFLogger protocol

var timeout: TimeInterval
default = 30
Allows child classes to modify the amount of time a request will wait for a response.

var keysToScrub: [String]
default = ["password"]
Allows child classes to define what JSON keys are obscured when logged

var restMethod: RFMethod
default = .get
Allows child classes to define the rest method to use (e.g GET, POST, PUT, DELETE, etc.)

var domain: String
Allows child classes to define the root domain of their REST service (e.g. https://google.com)

var rootPath: String
Allows child classes to defile the root api path for their REST service (e.g. /api/v1)

var pathResource: String
Allows child classes to define the restful resource path for each endpoint (e.g. /user/auth)

var queryArguments: [String: String]
Allows child classes to define the list of query arguments to include in the request URL
All keys and values will be URL encoded by the framework

var requestBody: String
Allows child classes to set the body of the request (i.e. JSON string, http url ecoded string)

var requestHeaders: [String: String]
Allows child classes to define the request headers to be sent to the server

func createResponse(responseTime: Double, code: Int, headers: [String: String], data: Data?) -> T.ResponseType?
default = instance of generic type provided from response string
Allows child classes to perform additional processing on response objects before reporting success
responseTime - The amount of time in seconds the response took
code - the response code reported by the service
headers - a key-value mapping of response headers
data - the raw data sent by the service response
```

# Invoking a request

```swift
let request = MyRequest()
request.successCallback = { code, response in // process response }
request.errorCallback = { error in // process error }
request.setCustomRequestVariables() // set any arguments for the request defined by the subclass
request.fetch()
```

# Response Wrapper Types
This library is wquipped to handle most kinds of responses, but users can define additional behavior by implementing the RFDecodable protocol

```swift
associatedType ResponseType // the generic type that this response will return in callbacks
acceptType: String? // the value to auto-inject into the Accept http header
object: ResponseType // the value of the response
init?(data: Data) // an init method for generating the response object
```

# Included Response Wrappers
```swift
RFVoidResponse // for services that are expected to return no body
RFDataResponse // for services that are expected to return binary data (e.g. files, images, etc.)
RFStringResponse // for services that are expected to return raw string data
RFDecodableResponse<T: Decodable> // for services that return JSON requres a Decodable object to decode the JSON into
RFRawResponse<T> // for responses where the user wishes to generate the response by overriding createResponse()
```
## Author

Charles Oder, charles@oder.us

## License

RestFetcher is available under the MIT license. See the LICENSE file for more info.
