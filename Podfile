# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'ENG' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
 
  pod 'Adjust'
  pod 'RevenueCat'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseRemoteConfig'
  pod 'FBSDKCoreKit'
  pod 'FBAudienceNetwork'
  pod 'OneSignalXCFramework'
  pod 'MailchimpSDK'
  
  pod 'AppLovinMediationByteDanceAdapter'
  pod 'AppLovinMediationGoogleAdManagerAdapter'
  pod 'AppLovinMediationGoogleAdapter'
  pod 'AppLovinMediationMaioAdapter'
  pod 'AppLovinMediationUnityAdsAdapter'
  pod 'AppLovinMediationVungleAdapter'
  
  pod 'AppLovinSDK'
  pod 'Purchasely' 
  
  pod 'AppsFlyerFramework'
  pod 'AppsFlyer-AdRevenue'
  
  pod 'Adapty', '~> 2.7.0'
  pod 'AdaptyUI', '~> 2.0.1'
  
  post_install do |installer|
     xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
             # For xcode 15+ only
              if config.base_configuration_reference && Integer(xcode_base_version) >= 15
                 xcconfig_path = config.base_configuration_reference.real_path
                 xcconfig = File.read(xcconfig_path)
                 xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                 File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
             end
         end
     end
 end
  
 
end
