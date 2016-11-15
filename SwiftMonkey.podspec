Pod::Spec.new do |s|
  s.name         = "SwiftMonkey"
  s.version      = "0.0.2"
  s.summary      = "Monkey testing framework for iOS apps"
  s.description  = <<-DESC
                   A framework for generating randomised user
                   input in iOS apps. This kind of monkey testing
                   is useful for stress-testing apps and finding
                   rare crashes.
                   DESC
  s.homepage     = "https://github.bus.zalan.do/dagren/SwiftMonkey"
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { "Dag Ågren" => "dag.agren@zalando.fi" }
  s.social_media_url = "http://twitter.com/WAHa_06x36"
  s.platform     = :ios, '9.0'
  s.source       = { :git => "git@github.bus.zalan.do:dagren/SwiftMonkey.git", :tag => "#{s.version}" }
  s.source_files = "*.swift"
  s.exclude_files = "Package.swift"
  s.framework    = 'XCTest'
end
