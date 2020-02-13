Pod::Spec.new do |s|
  s.name         = "AeroGear-UPS-Client"
  s.version      = "3.1.0"
  s.summary      = "AeroGear UnifiedPush Client Registration SDK (Swift)."
  s.homepage     = "https://github.com/aerogear/aerogear-ios-push"
  s.license      = 'Apache License, Version 2.0'
  s.author       = "Red Hat, Inc."
  s.source       = { :git => 'https://github.com/aerogear/aerogear-ios-push.git', :tag => s.version }
  s.platform     = :ios, 9.0
  s.source_files = 'AeroGearPush/*.{swift}'
  s.module_name  = "AeroGearPush"
  s.framework    = "Foundation"
  s.requires_arc = true
end
