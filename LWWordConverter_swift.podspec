#
# Be sure to run `pod lib lint LWWordConverter_swift.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'LWWordConverter_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift version of LWWordConverter - Chinese character processing library'

  s.description      = <<-DESC
LWWordConverter_swift is a Swift version of the LWWordConverter library.
It provides a modern Swift API for Chinese character processing including:
- Pinyin and Wubi encoding queries
- Text translation using Bing Translator API
- Text encryption and decryption with steganographic display
- Network reachability monitoring

This Swift version provides a more idiomatic API for Swift applications
while maintaining all the functionality of the original Objective-C version.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWWordConverter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWWordConverter.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  # Swift source files
  s.source_files = 'LWWordConverter_swift/Classes/**/*.swift'

  # Build settings
  s.xcconfig = {
      'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DSQLITE_THREADSAFE -DSQLITE_TEMP_STORE=2 -DSQLCIPHER_CRYPTO_CC',
      'OTHER_LDFLAGS' => '$(inherited) -framework Security',
      'WARNING_CFLAGS' => '-Wno-implicit-function-declaration',
      'SWIFT_VERSION' => '5.0'
  }

  # Dependencies
  s.dependency 'SQLCipher', '~> 4.0'
  s.dependency 'LWReachabilityManager'

end
