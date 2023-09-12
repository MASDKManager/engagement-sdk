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
import FirebaseRemoteConfig
import FBSDKCoreKit
import AppTrackingTransparency
import OneSignalFramework
import RevenueCat
import MailchimpSDK
import AppLovinSDK

public class EMobi: NSObject, PurchasesDelegate {
    
    public static let shared = EMobi()
    
    private var isSubscribed = false {
        didSet {
            if isSubscribed {
                distroyAds()
            }
        }
    }
    
    private var isPremium = false {
        didSet {
            if isPremium {
                distroyAds()
            }
        }
    }
    
    private var PurchasesIsConfigured = false
    private var OneSignalIsConfigured = false
    private var showATTonLaunch = false
    private var launchOptions : [UIApplication.LaunchOptionsKey: Any]?
    public weak var delegate: EMobiDelegate?
    
    private var adjustDelegateHandler: AdjustDelegateHandler?
    
    public override init() {
        adjustDelegateHandler = AdjustDelegateHandler()
    }
    
    public func start( launchOptions: [UIApplication.LaunchOptionsKey: Any]? , completion: @escaping (Bool) -> Void) {
        print( tag + "EMobi SDK started.")
        
        // Constant.shared.getValuesFromPlist()
        
        checkUserSubscription()
        
        self.launchOptions = launchOptions
        
        configureFirebaseAndFetchRemoteConfig { success in
            if success {
                completion(true)
                print("Remote config fetch and activation succeeded.")
                // Do something on success
            } else {
                completion(false)
                print("Remote config fetch and activation failed.")
                // Do something on failure
            }
        }
         
    }
    
    func configureFirebaseAndFetchRemoteConfig(completion: @escaping (Bool) -> Void) {
        
        // Step 1: Configure FirebaseApp (if not already configured)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Step 2: Set default values for RemoteConfig
        let appDefaults: [String: Any] = [
            "run": true,
        ]
        
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
        
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        // Step 3: Fetch RemoteConfig values from the server
        RemoteConfig.remoteConfig().fetch { (status, error) in
            if status == .success {
                // Step 4: Activate fetched values
                RemoteConfig.remoteConfig().activate { (changed, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error activating RemoteConfig: \(error.localizedDescription)")
                            completion(false)
                            // Handle any potential error here, if needed
                            return
                        }
                        
                        // Step 5: Apply fetched values to appropriate properties
                        self.applyFetchedValues()
                        completion(true)
                    }
                }
            } else {
                // Handle error during fetch
                print("Config not fetched")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Unknown error occurred.")
                }
                completion(false)
            }
        }
    }
    
    private func applyFetchedValues() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        let configKeys: [String: String] = [
            "onboardPaywallPlacementID": PurchaselyManager.shared.onboardPaywallPlacementID,
            "premiumPaywallPlacementID": PurchaselyManager.shared.premiumPaywallPlacementID,
            "adjustAppToken": Constant.shared.adjustAppToken,
            "adjustEventToken": Constant.shared.adjustEventToken,
            "adjustSubscriptionToken": Constant.shared.adjustSubscriptionToken,
            "adjustRestoreToken": Constant.shared.adjustRestoreToken,
            "adjustConversionToken": Constant.shared.adjustConversionToken,
            "revenuecatAPIKey": Constant.shared.revenuecatAPIKey,
            "oneSignalKey": Constant.shared.oneSignalKey,
            "purchaselyAPIKey": Constant.shared.purchaselyAPIKey,
            "mailchimpKey": Constant.shared.mailchimpKey,
            "facebookAppID": Constant.shared.facebookAppID,
            "facebookClientToken": Constant.shared.facebookClientToken,
            "facebookDisplayName": Constant.shared.facebookDisplayName,
            "applovinInterstitialKey": Constant.shared.applovinInterstitialKey,
            "applovinBannerKey": Constant.shared.applovinBannerKey,
            "appLovinSdkKey": Constant.shared.appLovinSdkKey,
            "showATTonLaunch": ""
        ]
        
        for (key, _) in configKeys {
            if let stringValue = remoteConfig[key].stringValue, !stringValue.isEmpty {
                switch key {
                case "onboardPaywallPlacementID":
                    PurchaselyManager.shared.onboardPaywallPlacementID = stringValue
                case "premiumPaywallPlacementID":
                    PurchaselyManager.shared.premiumPaywallPlacementID = stringValue
                case "adjustAppToken":
                    Constant.shared.adjustAppToken = stringValue
                case "adjustEventToken":
                    Constant.shared.adjustEventToken = stringValue
                case "adjustSubscriptionToken":
                    Constant.shared.adjustSubscriptionToken = stringValue
                case "adjustRestoreToken":
                    Constant.shared.adjustRestoreToken = stringValue
                case "adjustConversionToken":
                    Constant.shared.adjustConversionToken = stringValue
                case "revenuecatAPIKey":
                    Constant.shared.revenuecatAPIKey = stringValue
                case "oneSignalKey":
                    Constant.shared.oneSignalKey = stringValue
                case "purchaselyAPIKey":
                    Constant.shared.purchaselyAPIKey = stringValue
                case "mailchimpKey":
                    Constant.shared.mailchimpKey = stringValue
                case "facebookAppID":
                    Constant.shared.facebookAppID = stringValue
                case "facebookClientToken":
                    Constant.shared.facebookClientToken = stringValue
                case "facebookDisplayName":
                    Constant.shared.facebookDisplayName = stringValue
                case "applovinInterstitialKey":
                    Constant.shared.applovinInterstitialKey = stringValue
                case "applovinBannerKey":
                    Constant.shared.applovinBannerKey = stringValue
                case "appLovinSdkKey":
                    Constant.shared.appLovinSdkKey = stringValue
                case "showATTonLaunch":
                    showATTonLaunch = remoteConfig[key].boolValue
                default:
                    break
                }
            }
        }
        
        if !Constant.shared.adjustAppToken.isEmpty {
            configureAdjust()
        }
        
        if !Constant.shared.revenuecatAPIKey.isEmpty {
            configureRevenueCat()
        }
        
        if !Constant.shared.oneSignalKey.isEmpty {
            configureOneSignal()
        }
        
        if !Constant.shared.purchaselyAPIKey.isEmpty {
            PurchaselyManager.shared.initializePurchasely()
        }
        
        if !Constant.shared.mailchimpKey.isEmpty {
            configureMailchimp()
        }
        
        if !Constant.shared.appLovinSdkKey.isEmpty {
            AppLovinManager.shared.initializeAppLovin()
        }
        
        if !Constant.shared.facebookAppID.isEmpty &&
            !Constant.shared.facebookClientToken.isEmpty &&
            !Constant.shared.facebookDisplayName.isEmpty {
            configureFacebook()
        }
        
        if self.showATTonLaunch {
            self.requestIDFA(fromInside: true)
        }
        
        PurchaselyManager.shared.firebaseRemoteConfigLoaded = true
    }
    
    
    private func checkUserSubscription(){
        isPremium =  checkPremiumStatus()
        isSubscribed =  checkSubscriptionStatus()
    }
    
    private func configureOneSignal() {
        
        guard !Constant.shared.oneSignalKey.isEmpty else {
            print( "oneSignalKey sdk key are empty")
            return
        }
         
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
        // OneSignal initialization
        OneSignal.initialize(Constant.shared.oneSignalKey, withLaunchOptions: launchOptions)
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        
        if (!showATTonLaunch){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                OneSignal.User.pushSubscription.optIn()
            }
        }
        
        if let onesignalId = OneSignal.User.pushSubscription.id {
            Purchases.shared.attribution.setOnesignalID(onesignalId)
        }
        
        self.OneSignalIsConfigured = true
        
    }
    
    private func configureRevenueCat() {
        let appUserID = getUserID()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constant.shared.revenuecatAPIKey, appUserID: appUserID)
        
        checkSubscription()
        
        // Automatically collect the $idfa, $idfv, and $ip values
        Purchases.shared.attribution.collectDeviceIdentifiers()
        // REQUIRED: Set the Facebook anonymous Id
        Purchases.shared.attribution.setFBAnonymousID(FBSDKCoreKit.AppEvents.shared.anonymousID)
        
        if let adjustId = Adjust.adid() {
            Purchases.shared.attribution.setAdjustID(adjustId)
        }
         
        Purchases.shared.delegate = self
        
        // Set the reserved $firebaseAppInstanceId subscriber attribute from Firebase Analytics
        let instanceID = Analytics.appInstanceID();
        if let unwrapped = instanceID {
            print( tag + "Instance ID -> " + unwrapped);
            print( tag + "Setting Attributes");
            Purchases.shared.attribution.setFirebaseAppInstanceID(unwrapped)
        } else {
            print( tag + "Instance ID -> NOT FOUND!");
        }
        
        Purchases.shared.attribution.setAttributes(["user_uuid" : getUserID()])
        PurchasesIsConfigured = true
        
    }
    
    public func requestIDFA(fromInside: Bool = false) {
        
        if !fromInside && showATTonLaunch {
            return
        }
        
        if #available(iOS 14.3, *) {
            // Check the ATT consent status.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    
                    if self.PurchasesIsConfigured {
                        Purchases.shared.attribution.setAttributes(["ATTrackingManagerStatus": statusCase])
                        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
                    }
                    
                    if self.OneSignalIsConfigured && self.showATTonLaunch {
                        OneSignal.User.pushSubscription.optIn()
                    }
                }
            }
        }
    }
    
    private func setPurchasesEmail(email : String){
        Purchases.shared.attribution.setEmail(email)
    }
    
    private func checkSubscription(){
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if ((customerInfo?.activeSubscriptions.count ?? 0) != 0){
                self.isSubscribed = true
            }
        }
        
    }
    
    private func configureAdjust() {
        print("Adjust initiate called")
        #if DEBUG
                print("Not App Store build")
                let environment = ADJEnvironmentSandbox
        #else
                print("App Store build")
                let environment = ADJEnvironmentProduction
        #endif
        
        
        let adjustConfig = ADJConfig(appToken: Constant.shared.adjustAppToken, environment: environment)
        
        adjustConfig?.sendInBackground = true
        adjustConfig?.linkMeEnabled = true
        adjustConfig?.delegate = adjustDelegateHandler
        
        //   adjustConfig?.delegate = self
        
        Adjust.appDidLaunch(adjustConfig)
        
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        Adjust.addSessionCallbackParameter("m_sdk_ver", value: versionNumber)
        Adjust.addSessionCallbackParameter("user_uuid", value: getUserID())
        
        let faid = Analytics.appInstanceID() ?? ""
        let adjustEvent = ADJEvent(eventToken: Constant.shared.adjustEventToken)
        adjustEvent?.addCallbackParameter("eventValue", value: faid) // Firebase Instance Id
        adjustEvent?.addCallbackParameter("click_id", value: getUserID())
        
        Adjust.trackEvent(adjustEvent)
        
    }
    
    private func configureFacebook() {
        
        if Constant.shared.facebookAppID.isEmpty || Constant.shared.facebookDisplayName.isEmpty ||  Constant.shared.facebookClientToken.isEmpty
        {
            print( "Facebook sdk keys are empty")
            return
        }
        
        let sdkSettings = FBSDKCoreKit.Settings()
        sdkSettings.appID = Constant.shared.facebookAppID
        sdkSettings.displayName = Constant.shared.facebookDisplayName
        sdkSettings.clientToken = Constant.shared.facebookClientToken
        print( tag + "Facebook sdk init")
    }
    
    private func configureMailchimp() {
        
        if Constant.shared.mailchimpKey.isEmpty
        {
            print( "Mailchimp sdk key are empty")
            return
        }
        
        try? Mailchimp.initialize(token: Constant.shared.mailchimpKey, autoTagContacts: true, debugMode: false)
        
        print( tag + "Mailchimp sdk init")
        
    }
    
    private func distroyAds(){
        AppLovinManager.shared.unloadAds()
    }
    
    public func registerEmail(email: String) {
        if Constant.shared.mailchimpKey.isEmpty
        {
            print( "Mailchimp sdk key are empty")
            return
        }
        
        if self.PurchasesIsConfigured {
            Purchases.shared.attribution.setEmail(email)
        }
        
        var contact: Contact = Contact(emailAddress: email)
        //  contact.marketingPermissions = [emailPermission, mailPermission, advertisingPermission]
        
        let mergeFields = ["mobile": MergeFieldValue.string("signup") ]
        contact.status = .subscribed
        contact.mergeFields = mergeFields
        contact.tags = [Contact.Tag(name: "mobile-signup", status: .active)]
        Mailchimp.createOrUpdate(contact: contact) { result in
            switch result {
            case .success:
                print( tag + "Mailchimp Successfully added or updated contact")
            case .failure(let error):
                print( tag + "Mailchimp Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    public func logAnalyticsEvent(name: String, parameter: [String: Any]) {
        logEvent(eventName: name, parameters: parameter)
        
        print( tag + "Firebase logEvent sent")
    }
    
    public func sendConversionEvent(eventData: [String: String]) {
        AdjustManager.shared.sendConversionEvent(eventData: eventData)
    }
    
    public func isSubscribedUser( )  -> Bool {
        return  isSubscribed
    }
    
    public func setSubscribedUser(isSubscribed : Bool )   {
        self.isSubscribed = isSubscribed
    }
    
    public func isPremiumUser( )  -> Bool {
        return  isPremium
    }
    
    public func setPremiumUser(isPremium : Bool )   {
        self.isPremium = isPremium
    }
    
    public func getAllPurchasedProductIdentifiers(completion: @escaping (Set<String>?) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let customerInfo = customerInfo {
                completion(customerInfo.allPurchasedProductIdentifiers)
            } else {
                completion(nil)
            }
        }
    }
    
    
    public func restorePurchases(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        PurchaselyManager.shared.restoreAllProducts(success: {
            // Reload content and display a success / thank you message to the user
            success() // Call the success callback
        }, failure: { error in
            // Display error
            failure(error) // Call the failure callback and pass the error
        })
    }
    
    public  func loadBannerAd(vc : UIViewController, bannerView: UIView  ) {
        if(isPremium || isSubscribed){
            return
        }
        
        AppLovinManager.shared.loadBannerAd(vc: vc, adViewContainer: bannerView )
    }
    
    public func showInterestialAd(onClose: @escaping (Bool) -> ()) {
        if(isPremium || isSubscribed){
            return
        }
        
        AppLovinManager.shared.showInterestialAd(onClose: onClose)
    }
    
    public func showPaywall(type: PaywallType = .paywall, completionSuccess: (() -> Void)? = nil, completionFailure: (() -> Void)? = nil) -> UIViewController? {
        if isPremium || isSubscribed {
            // Do something else here or just return nil if you don't need to show any paywall.
            return nil
        }
        
        return PurchaselyManager.shared.showPurchaselyPaywall(type: type, completionSuccess: completionSuccess, completionFailure: completionFailure)
    }
    
    public static func handleOpenURL(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Custom handling code here
        return true
    }
    
}
