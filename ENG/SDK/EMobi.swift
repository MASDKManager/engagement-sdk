//
//  EMobi.swift
//  ENGSDK
//
//  Created by Maarouf on 6/27/23.
//

import Foundation
import FirebaseCore
import Adjust
import FirebaseAnalytics
import FirebaseInstallations
import FBSDKCoreKit
import AppTrackingTransparency
import OneSignal
import RevenueCat
 
public class EMobi: NSObject, PurchasesDelegate , OSSubscriptionObserver{
  
    
    public static let shared = EMobi()
    
    private override init() {
        // Private initializer to enforce singleton pattern
    }
    
    public func start(withConstantPlist plistData: NSDictionary, launchOptions: [UIApplication.LaunchOptionsKey: Any]?  ) {
        print("EMobi SDK started.")

        Constant.shared.getValuesFromPlist()
        
        let adjustToken = Constant.shared.adjustAppToken
        let revenueCatAPIKey = Constant.shared.rcAPIKey
        let appPushToken = Constant.shared.appPushToken
         
        configureRevenueCat(apiKey: revenueCatAPIKey,appPushToken: appPushToken)
        configureFirebase()
        configureAdjust(token: adjustToken)
        configureOneSignal(appPushToken: appPushToken,launchOptions: launchOptions)
        configureFacebook()
    }
    
    private func configureOneSignal(appPushToken: String,launchOptions : [UIApplication.LaunchOptionsKey: Any]?  ) {
        
        if appPushToken == "" {
            return
        }
         
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(appPushToken)
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        
        if let onesignalId = OneSignal.getDeviceState().userId {
            Purchases.shared.attribution.setOnesignalID(onesignalId)
        }
        
        
    }
    
    public func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
             // The user is subscribed
             // Either the user subscribed for the first time
             Purchases.shared.attribution.setOnesignalID(stateChanges.to.userId)
         }
    }
     
    private func configureFirebase() {
        FirebaseApp.configure()
    }
    
    private func configureRevenueCat(apiKey: String,appPushToken: String) {
        let appUserID = getUserID()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey, appUserID: appUserID)
        
        checkSubscription()

        // Automatically collect the $idfa, $idfv, and $ip values
        Purchases.shared.attribution.collectDeviceIdentifiers()
        // REQUIRED: Set the Facebook anonymous Id
        Purchases.shared.attribution.setFBAnonymousID(FBSDKCoreKit.AppEvents.shared.anonymousID)
     
        if let adjustId = Adjust.adid() {
            Purchases.shared.attribution.setAdjustID(adjustId)
        }
        
        Purchases.shared.attribution.setOnesignalID(appPushToken)
         
        Purchases.shared.delegate = self

        // Set the reserved $firebaseAppInstanceId subscriber attribute from Firebase Analytics
        let instanceID = Analytics.appInstanceID();
        if let unwrapped = instanceID {
          print("Instance ID -> " + unwrapped);
            print("Setting Attributes");
          Purchases.shared.attribution.setFirebaseAppInstanceID(unwrapped)
         } else {
            print("Instance ID -> NOT FOUND!");
         }
        
        Purchases.shared.attribution.setAttributes(["user_uuid" : getUserID()])
         
        // Check the ATT consent status.
        let status = ATTrackingManager.trackingAuthorizationStatus

        // If the status is not determined, show the prompt.
    
        
        if status == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { status in
                
                var statusCase = ""
                
                switch status {
                case .authorized:
                    statusCase = "The user has granted consent."
                case .denied:
                    statusCase = "The user has denied consent."
                case .notDetermined:
                    statusCase = "The user has not yet been asked for consent."
                case .restricted:
                    statusCase = "The user is restricted from granting consent."
                @unknown default:
                        return
                }
                
                Purchases.shared.attribution.setAttributes(["ATTrackingManagerStatus" : statusCase])
            }
        }
    }
    
    private func setPurchasesEmail(email : String){
        Purchases.shared.attribution.setEmail(email)
    }
    
    private func checkSubscription(){
        
        // Using Completion Blocks
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            if customerInfo?.entitlements.all[<your_entitlement_id>]?.isActive == true {
//                   // User is "premium"
//            }
        }
        
    }
    
    private func configureAdjust(token: String) {
        print("Adjust initiate called with token")
        
        let adjustConfig = ADJConfig(appToken: token, environment: ADJEnvironmentProduction)
        
        adjustConfig?.sendInBackground = true
        adjustConfig?.linkMeEnabled = true
        
        Adjust.appDidLaunch(adjustConfig)
         
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
      
        Adjust.addSessionCallbackParameter("m_sdk_ver", value: versionNumber)
        Adjust.addSessionCallbackParameter("user_uuid", value: getUserID())
        
        let faid = Analytics.appInstanceID() ?? ""
        let adjustEvent = ADJEvent(eventToken: token)
        adjustEvent?.addCallbackParameter("eventValue", value: faid) // Firebase Instance Id
        adjustEvent?.addCallbackParameter("click_id", value: getUserID())
        
        Adjust.trackEvent(adjustEvent)
    }
    
   private func configureFacebook() {
       let sdkSettings = FBSDKCoreKit.Settings()
       sdkSettings.appID = "798130175032196"
       sdkSettings.displayName = "App"
        
 
   }
    
    public func logAnalyticsEvent(name: String, parameter: String) {
        logEvent(eventName: name, log: parameter)
    }
}
