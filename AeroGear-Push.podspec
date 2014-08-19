Pod::Spec.new do |s|
  s.name         = "AeroGear-Push"
  s.version      = "1.0.0"
  s.summary      = "AeroGear UnifiedPush Client Registration SDK."
  s.homepage     = "https://github.com/aerogear/aerogear-ios-push"
  s.license      = 'Apache License, Version 2.0'
  s.author       = "Red Hat, Inc."
  s.source       = { :git => 'https://github.com/aerogear/aerogear-ios-push.git', :tag => '1.0.0' }
  s.platform     = :ios, 7.0
  s.source_files = 'push-sdk/**/*.{h,m}'
  s.public_header_files = 'push-sdk/AeroGearPush.h', 'push-sdk/AGDeviceRegistration.h', 'push-sdk/AGClientDeviceInformation.h'
  s.requires_arc = true
end
