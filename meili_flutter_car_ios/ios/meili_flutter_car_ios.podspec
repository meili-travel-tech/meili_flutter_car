#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'meili_flutter_ios'
  s.version          = '0.0.1'
  s.summary          = 'An iOS implementation of the meili_flutter plugin.'
  s.description      = <<-DESC
  An iOS implementation of the meili_flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'meili_flutter_ios/Sources/meili_flutter_ios/**/*.swift'
  s.dependency 'Flutter'
  
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'MeiliSDK', '1.11.1'
end
