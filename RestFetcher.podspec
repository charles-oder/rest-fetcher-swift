
Pod::Spec.new do |s|

  s.name          = "RestFetcher"
  s.version       = "1.1.1"
  s.summary       = "A simple framework for making api calls."
  s.description   = "This is a simple library for supporting a family of API calls."
  s.homepage      = "https://github.com/charles-oder/rest-fetcher-swift"
  s.license       = { :type => "MIT", :file => "LICENSE.txt" }
  s.author        = { "Charles Oder" => "charles@oder.us" }
  s.source        = { :git => "https://github.com/charles-oder/rest-fetcher-swift.git", :branch => "s.version.to_s", :tag => s.version.to_s }

  s.source_files  = "Classes", "RestFetcher/*.swift"
  s.exclude_files = "Classes/Exclude"
  s.platform      = :ios, "8.0"

end
