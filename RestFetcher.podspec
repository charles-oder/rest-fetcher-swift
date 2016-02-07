
Pod::Spec.new do |s|

  s.name         = "RestFetcher"
  s.version      = "1.0.1"
  s.summary      = "A simple framework for making api calls."
  s.description  = "This is a simple library for supporting a family of API calls."
  s.homepage     = "https://github.com/charles-oder/rest-fetcher-swift"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = { "Charles Oder" => "charles@oder.us" }
  s.source       = { :git => "https://github.com/charles-oder/rest-fetcher-swift.git", :tag => "1.0.0" }
  s.source_files  = "Classes", "RestFetcher/*.swift"
  s.exclude_files = "Classes/Exclude"
  s.platform     = :ios, "8.0"

end
