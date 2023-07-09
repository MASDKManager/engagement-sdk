Pod::Spec.new do |spec|

  spec.platform = :ios
  spec.name         = "ENGSDK"
  spec.version      = "0.0.1"
  spec.requires_arc =  true
  spec.summary      = "ENGSDK - Boost User Engagement."
  spec.description  = <<-DESC
  ENGSDK is a powerful engagement toolkit designed to elevate user interaction and connectivity within your app and mobibox.
                      DESC
  spec.homepage     = 'https://github.com/MASDKManager/engagement-sdk'
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "ENGSDK" => "mobsdk10@gmail.com" }
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
  spec.dependency 'FBSDKCoreKit'  
  spec.dependency 'OneSignalXCFramework'   
 
  spec.source_files  = "ENG/SDK/**/*.{h,m,swift}"
  spec.resource_bundles = {
    'ENGSDK' => ['ENG/SDK/**/*.{storyboard,xib,xcassets,lproj,png}']
  }
  spec.swift_version = '5'
  spec.ios.deployment_target = '14.0'

  spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  spec.static_framework = true
end
