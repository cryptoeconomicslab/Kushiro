Pod::Spec.new do |s|
  s.name             = 'Kushiro'
  s.version          = '0.1.0'
  s.summary          = 'Kushiro is an experimental ovm implementation in Swift.'

  s.description      = <<-DESC
A client library for the optimistic virtual machine as described by
the plasma group. Developed by Cryptoeconomicslab.
                       DESC

  s.homepage         = 'https://github.com/cryptoeconomicslab/Kushiro'
  s.license          = 'Currently all rights reserved. Check out later for open source.'
  s.author           = { 'Koray Koska' => 'koray@koska.at' }
  s.source           = { :git => 'https://github.com/cryptoeconomicslab/Kushiro.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/cryptoeconlab'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.swift_version = '5.1.2'

  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-DKushiroCocoaPods'
  }

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Kushiro/Core/**/*'

    # Core dependencies
  end
end
