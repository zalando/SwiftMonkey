Pod::Spec.new do |s|
  s.name         = "SwiftMonkey"
  s.version      = "2.1.1"
  s.summary      = "Monkey testing framework for iOS apps"
  s.description  = <<-DESC
                   A framework for generating randomised user
                   input in iOS apps. This kind of monkey testing
                   is useful for stress-testing apps and finding
                   rare crashes.
                   DESC
  s.homepage     = "https://github.com/zalando/SwiftMonkey"
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { "Dag Ågren" => "dag.agren@zalando.fi" }
  s.social_media_url = "http://twitter.com/WAHa_06x36"
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/zalando/SwiftMonkey.git", :tag => "#{s.version}" }
  s.source_files = "SwiftMonkey/*.swift"
  s.exclude_files = "SwiftMonkey/Package.swift"
  s.framework    = "XCTest"
  s.swift_version = "4.2"
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
