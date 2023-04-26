

Pod::Spec.new do |spec|
  spec.name         = 'MKPlayer'
  spec.summary      = 'AVPlayer wrapper'
  spec.version      = '0.0.2'
  spec.authors      = {
    'Jovan Stojanov' => 'railjoe@gmail.com'
  }
  spec.homepage     = 'https://github.com/railjoe/MKPlayer'
  spec.source       = {
    :git => 'https://github.com/railjoe/MKPlayer.git',
    :branch => 'master',
    :tag => spec.version.to_s
  }
  spec.source_files = 'source/**/*.swift'
  spec.resources = 'source/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
  spec.swift_versions = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.18.5'
end
