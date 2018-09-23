Pod::Spec.new do |s|
  s.name         = "SwiftMonkeyPaws"
  s.version      = "2.1.1"
  s.summary      = "Visualisation of input events, especially useful during UI testing."
  s.description  = <<-DESC
                   Visualise all touch events in a layer on top of
                   your UI. This is meant to be paired with the
                   SwiftMonkey monkey testing library, but can also
                   be used on its own.
                   DESC
  s.homepage     = "https://github.com/zalando/SwiftMonkey"
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.author       = { "Dag Ågren" => "dag.agren@zalando.fi" }
  s.social_media_url = "http://twitter.com/WAHa_06x36"
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/zalando/SwiftMonkey.git", :tag => "#{s.version}" }
  s.source_files = "SwiftMonkeyPaws/*.swift"
  s.swift_version = "4.2"
  s.exclude_files = "SwiftMonkeyPaws/Package.swift"
end
