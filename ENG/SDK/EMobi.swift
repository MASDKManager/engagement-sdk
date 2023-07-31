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
import OneSignal
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
    private var showATTonLaunch = false
    public weak var delegate: EMobiDelegate?
     
    private var adjustDelegateHandler: AdjustDelegateHandler?
    
    public override init() {
        adjustDelegateHandler = AdjustDelegateHandler()
    }
     
    public func start(withConstantPlist plistData: NSDictionary, launchOptions: [UIApplication.LaunchOptionsKey: Any]?  ) {
        print( tag + "EMobi SDK started.")

        Constant.shared.getValuesFromPlist()
          
        configureFirebaseAndFetchRemoteConfig()
        checkUserSubscription()
            
        configureAdjust()
        configureRevenueCat()
        configureOneSignal(launchOptions: launchOptions)
        configureFacebook()
        configureMailchimp()
        AppLovinManager.shared.initializeAppLovin()
        PurchaselyManager.shared.initializePurchasely()
        
    }
    
    func configureFirebaseAndFetchRemoteConfig() {
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
                            // Handle any potential error here, if needed
                            return
                        }
                        
                        // Step 5: Apply fetched values to appropriate properties
                        self.applyFetchedValues()
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
            }
        }
    }

    private func applyFetchedValues() {
      
        PurchaselyManager.shared.onboardPaywallPlacementID = RemoteConfig.remoteConfig()["onboardPaywallPlacementID"].stringValue ?? ""
        PurchaselyManager.shared.premiumPaywallPlacementID = RemoteConfig.remoteConfig()["premiumPaywallPlacementID"].stringValue ?? ""
        PurchaselyManager.shared.showPurchaselyPaywall = RemoteConfig.remoteConfig()["showPurchaselyPaywall"].boolValue
        
        self.showATTonLaunch =  RemoteConfig.remoteConfig()["showATTonLaunch"].boolValue
        
        if self.showATTonLaunch {
            self.requestIDFA(fromInside: true)
        }
        
        PurchaselyManager.shared.firebaseRemoteConfigLoaded = true
    }
 
    private func checkUserSubscription(){
        isPremium =  checkPremiumStatus()
        isSubscribed =  checkSubscriptionStatus()
    }
    
    private func configureOneSignal( launchOptions : [UIApplication.LaunchOptionsKey: Any]?  ) {
        
        guard !Constant.shared.oneSignalKey.isEmpty else { 
            print( "oneSignalKey sdk key are empty")
            return
        }
         
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId( Constant.shared.oneSignalKey)
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print( tag + "User accepted notifications: \(accepted)")
            })
        }
        
        if let onesignalId = OneSignal.getDeviceState().userId {
            Purchases.shared.attribution.setOnesignalID(onesignalId)
        }
         
    }
   
    private func configureRevenueCat() {
        let appUserID = getUserID()
     
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constant.shared.rcAPIKey, appUserID: appUserID)
        
        checkSubscription()

        // Automatically collect the $idfa, $idfv, and $ip values
        Purchases.shared.attribution.collectDeviceIdentifiers()
        // REQUIRED: Set the Facebook anonymous Id
        Purchases.shared.attribution.setFBAnonymousID(FBSDKCoreKit.AppEvents.shared.anonymousID)
     
        if let adjustId = Adjust.adid() {
            Purchases.shared.attribution.setAdjustID(adjustId)
        }
        
        Purchases.shared.attribution.setOnesignalID(Constant.shared.oneSignalKey)
         
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
        
        let adjustConfig = ADJConfig(appToken: Constant.shared.adjustAppToken, environment: ADJEnvironmentSandbox)
        
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
        
       try? Mailchimp.initialize(token: Constant.shared.mailchimpKey, autoTagContacts: true, debugMode: true)
       
       print( tag + "Mailchimp sdk init")
        
    }

    private func distroyAds(){
        AppLovinManager.shared.unloadAds()
    }
    
    public func registerMailchimpEmail(email: String) {
        if Constant.shared.mailchimpKey.isEmpty
        {
            print( "Mailchimp sdk key are empty")
            return
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
    
    
    public func restorePurchases() {
        PurchaselyManager.shared.restoreAllProducts()
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
     
    public func showPurchaselyPaywall(type: PaywallType = .paywall, completionSuccess: (() -> Void)? = nil, completionFailure: (() -> Void)? = nil) -> UIViewController? {
        if isPremium || isSubscribed {
            // Do something else here or just return nil if you don't need to show any paywall.
            return nil
        }

        return PurchaselyManager.shared.showPurchaselyPaywall(completionSuccess: completionSuccess, completionFailure: completionFailure)
    }
 
}
