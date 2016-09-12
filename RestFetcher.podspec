#
# Be sure to run `pod lib lint RestFetcher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RestFetcher'
  s.version          = '1.3'
  s.summary          = 'A simple framework for making api calls.'


  s.description      = <<-DESC
This is a simple library for supporting a family of API calls.
                       DESC

  s.homepage         = 'https://github.com/charles-oder/rest-fetcher-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Charles Oder' => 'charles@oder.us' }
  s.source           = { :git => 'https://github.com/charles-oder/rest-fetcher-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'RestFetcher/**/*'
  
end
