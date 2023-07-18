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
import MailchimpSDK
import AppLovinSDK

 
public class EMobi: NSObject, PurchasesDelegate {
   
    public static let shared = EMobi()
    private var isSubscribed = false
    private var isPremium = false 
    weak var delegate: EMobiDelegate?
     
    private var adjustDelegateHandler: AdjustDelegateHandler?
    
    public override init() {
        adjustDelegateHandler = AdjustDelegateHandler()
    }
     
    public func start(withConstantPlist plistData: NSDictionary, launchOptions: [UIApplication.LaunchOptionsKey: Any]?  ) {
        print( tag + "EMobi SDK started.")

        Constant.shared.getValuesFromPlist()
         
        self.requestIDFA()
        
        checkPremiumUser()
           
        configureFirebase()
        configureAdjust()
        configureRevenueCat()
        configureOneSignal(launchOptions: launchOptions)
        configureFacebook()
        configureMailchimp()
        AppLovinManager.shared.initializeAppLovin()
       

    }
   
    private func checkPremiumUser(){
        isPremium =  checkPremiumStatus() 
    }
    
    private func configureOneSignal( launchOptions : [UIApplication.LaunchOptionsKey: Any]?  ) {
        
        guard !Constant.shared.oneSignalKey.isEmpty else {
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
 
    private func configureFirebase() {
        FirebaseApp.configure()
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
        
        Purchases.shared.attribution.setOnesignalID(Constant.shared.adjustEventToken)
         
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
     
    func requestIDFA() {
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
                    
                    Purchases.shared.attribution.setAttributes(["ATTrackingManagerStatus": statusCase])
                    Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
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
        let sdkSettings = FBSDKCoreKit.Settings()
        sdkSettings.appID = Constant.shared.facebookAppID
        sdkSettings.displayName = Constant.shared.facebookDisplayName
        sdkSettings.clientToken = Constant.shared.facebookClientToken
        print( tag + "Facebook sdk init")
   }
     
   private func configureMailchimp() {
       try? Mailchimp.initialize(token: Constant.shared.mailchimpKey, autoTagContacts: true, debugMode: true)
       
       print( tag + "Mailchimp sdk init")
        
   }
    
    func trackPurchaseEvent(purchaseToken: String, productID: String, transactionID: String) {
        let event = ADJEvent(eventToken: Constant.shared.adjustSubscriptionToken)
      
        event?.addCallbackParameter("user_uuid", value: getUserID())
        event?.addCallbackParameter("purchaseToken", value: purchaseToken)
        event?.addCallbackParameter("purchaseTime", value: "\(Date())")
        event?.addCallbackParameter("transactionId", value: transactionID)
        event?.addCallbackParameter("productId", value: productID)
        
        Adjust.trackEvent(event)
         
        print( tag + "trackPurchaseEvent sent init")
    }
    
    public func registerMailchimpEmail(email: String) {
       
     
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
     
    public func isActiveUser( )  -> Bool {
       return  isSubscribed
    }
     
    public func isPremiumUser( )  -> Bool {
      return  isPremium
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
     
    public  func loadBannerAd(vc : UIViewController, bannerView: UIView  ) {
        AppLovinManager.shared.loadBannerAd(vc: vc, adViewContainer: bannerView )
    }
    
    public func showInterestialAd(onClose: @escaping (Bool) -> ()) { 
        AppLovinManager.shared.showInterestialAd(onClose: onClose)
    }
    
    public func distroyAds(){
        AppLovinManager.shared.unloadBannerAd()
    }
 
}
