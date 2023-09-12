Pod::Spec.new do |spec|

  spec.platform = :ios
  spec.name         = "ENG"
  spec.version      = "0.9.6"
  spec.requires_arc =  true
  spec.summary      = "ENG - Boost User Engagement."
  spec.description  = <<-DESC
  ENG is a powerful engagement toolkit designed to elevate user interaction and connectivity within your app and mobibox.
                      DESC
  spec.homepage     = 'https://github.com/MASDKManager/engagement-sdk'
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "ENG" => "mobsdk10@gmail.com" }
  spec.source = {
    :git => 'https://github.com/MASDKManager/engagement-sdk.git',
    :tag => spec.version.to_s
  }
  spec.framework = 'UIKit'
  spec.dependency 'Adjust'
  spec.dependency 'RevenueCat'
  spec.dependency 'Firebase'
  spec.dependency 'FirebaseAnalytics'
  spec.dependency 'FirebaseCrashlytics'
  spec.dependency 'FirebaseRemoteConfig'
  spec.dependency 'FBSDKCoreKit'
  spec.dependency 'FBAudienceNetwork'
  spec.dependency 'OneSignalXCFramework'
  spec.dependency 'AppLovinMediationByteDanceAdapter'
  spec.dependency 'AppLovinMediationGoogleAdManagerAdapter'
  spec.dependency 'AppLovinMediationGoogleAdapter'
  spec.dependency 'AppLovinMediationMaioAdapter'
  spec.dependency 'AppLovinMediationUnityAdsAdapter'
  spec.dependency 'AppLovinSDK'
  spec.dependency 'MailchimpSDK'
  spec.dependency 'Purchasely', '3.7.2'
 
  spec.source_files  = "ENG/SDK/**/*.{h,m,swift}"
  # spec.resource_bundles = {
  #   'ENG' => ['ENG/SDK/**/*.storyboard', 'ENG/SDK/**/*.xib', 'ENG/SDK/**/*.xcassets', 'ENG/SDK/**/*.lproj', 'ENG/SDK/**/*.png']
  # }
  spec.swift_version = '5'
  spec.ios.deployment_target = '14.0'

  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  spec.static_framework = true
end
