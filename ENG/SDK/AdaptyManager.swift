//
//  PurchaselyManager.swift
//  ENG
//
//  Created by Maarouf on 7/19/23.
//

import Foundation
import Adapty
import AdaptyUI
import FirebaseCore
import FirebaseAnalytics
   
class AdaptyManager : NSObject, AdaptyPaywallControllerDelegate  {
   
    static let shared = AdaptyManager()
    
    var onboardPaywallPlacementID =   ""
    var premiumPaywallPlacementID = ""
    var showPurchaselyPaywall = false
    var firebaseRemoteConfigLoaded = false
    
    static var adapty : UIViewController?
    var completionSuccess: (() -> UIViewController)? = nil
    var completionFailure: (() -> Void)? = nil
    
    var apaywall: AdaptyPaywall?
    var lvconfig: AdaptyUI.LocalizedViewConfiguration?
 
    func initializeAdapty() {
        let key = Constant.shared.adaptyKey
        let user_uuid = getUserID()
         
        Adapty.activate(key, customerUserId: user_uuid)
        
        if let appInstanceId = Analytics.appInstanceID() {
            let builder = AdaptyProfileParameters.Builder()
                .with(firebaseAppInstanceId: appInstanceId)
                    
            Adapty.updateProfile(params: builder.build()) { error in
                        // handle error
            }
        }
    }
  
    func showPaywall(type: PaywallType = .paywall, completionSuccess: @escaping (UIViewController?) -> Void, completionFailure: (() -> Void)?) {
        Adapty.getPaywall(onboardPaywallPlacementID) { result in
            switch result {
            case let .success(paywall):
                self.apaywall = paywall
                
                self.fetchViewConfiguration { visualPaywall in
                    completionSuccess(visualPaywall) // Pass visualPaywall to the completionSuccess closure
                }
                 
            case let .failure(error):
                completionFailure?()
            }
            
        }
    }

 
    func fetchViewConfiguration(completionSuccess: @escaping (UIViewController?) -> Void) {
        
        AdaptyUI.getViewConfiguration(forPaywall: apaywall!, locale: "en") { [self] result in
            switch result {
            case let .success(viewConfiguration):
                lvconfig = viewConfiguration
                self.showVisualPaywall { visualPaywall in
                    completionSuccess(visualPaywall)
                }

            case let .failure(error):
                print(error)
            }
        }
    }

    func showVisualPaywall(completionSuccess: @escaping (UIViewController?) -> Void) {

        
        let visualPaywall = AdaptyUI.paywallController(
            for: apaywall!,
            viewConfiguration: lvconfig!,
            delegate: self
        )
         
        completionSuccess(visualPaywall)
    }



    
    func restoreAllProducts(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
  
        Adapty.restorePurchases { [weak self] result in
            switch result {
            case  .success(_):
                self?.checkSubscription()
                success()
                break
                     
            case let .failure(error):
                failure(error)
                break
            }
        }
         
    }

    func checkSubscription(){
      
    }
     
    public func paywallController(_ controller: AdaptyPaywallController, didSelectProduct product: AdaptyPaywallProduct) {
        

    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didStartPurchase product: AdaptyPaywallProduct) {
         
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didFinishPurchase product: AdaptyPaywallProduct, purchasedInfo: AdaptyPurchasedInfo) {
        
        print("User purchased: \(product.localizedTitle)")
        EMobi.shared.setSubscribedUser(isSubscribed: true)
        saveSubscriptionStatus(isSubscribed: EMobi.shared.isSubscribedUser())

        if EMobi.shared.getMMP() == MMP.adjust {
            
            AdjustManager.shared.trackPurchaseEvent(purchaseToken: Constant.shared.adjustSubscriptionToken, productID: product.vendorProductId , transactionID: purchasedInfo.transaction.transactionIdentifier ?? "")
            
        }else if EMobi.shared.getMMP() == MMP.appsflyer {
            
            let price = NSDecimalNumber(decimal: product.price ).doubleValue
            AppsFlyersManager.shared.trackPurchaseEvent(productID: product.vendorProductId , amount: price )
            
        }
        
        controller.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("DismissPaywall"), object: nil)

                     
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didCancelPurchase product: AdaptyPaywallProduct) {
         
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didFinishRestoreWith profile: AdaptyProfile) {
         
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didFailRestoreWith error: AdaptyError) {
         
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didFailRenderingWith error: AdaptyError) {
         
    }
    
    public func paywallController(_ controller: AdaptyPaywallController, didFailLoadingProductsWith error: AdaptyError) -> Bool {
         return true
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        NotificationCenter.default.post(name: Notification.Name("DismissPaywall"), object: nil)

        controller.dismiss(animated: true)
    }
    
    func paywallController(_ controller: AdaptyPaywallController, didFailPurchase product: AdaptyPaywallProduct, error: AdaptyError) {
        
    }
    
 
}
