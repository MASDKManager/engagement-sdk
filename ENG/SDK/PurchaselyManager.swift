//
//  PurchaselyManager.swift
//  ENG
//
//  Created by Maarouf on 7/19/23.
//

import Foundation
import Purchasely
import StoreKit
  
public enum PaywallType : String {
    case onboarding
    case paywall
}

class PurchaselyManager {
    static let shared = PurchaselyManager()
    
    var onboardPaywallPlacementID =   ""
    var premiumPaywallPlacementID = ""
    var showPurchaselyPaywall = false
    var firebaseRemoteConfigLoaded = false
    
    static var purhchasely : UIViewController?
    enum DurationUnit {
        case day
        case week
        case month
        case year
        case unknown
    }
    
    func initializePurchasely() {
        let key = Constant.shared.purchaselyAPIKey
        let user_uuid = getUserID()
  
        Purchasely.start(withAPIKey: key, appUserId: user_uuid, runningMode: .full, logLevel: .debug) { success, err in
            if (success) {
                print("purchasely initiaisation: success")
            } else {
                print("purchasely initiaisation: failed")
            }
        }
         
    }
  
    func showPaywall(type: PaywallType = .paywall, completionSuccess: @escaping (UIViewController?) -> Void, completionFailure: (() -> Void)?) {
     
        guard firebaseRemoteConfigLoaded else { 
            return
        }
            
        let placementId = (type == .onboarding) ? onboardPaywallPlacementID : premiumPaywallPlacementID
                
        let purhchasely = Purchasely.presentationController(for: placementId, loaded: { vc, isLoaded, err in
            
            print("placementId : \(placementId)")

            print("is presentation controller loaded: \(isLoaded)")

        },completion:  { result, plan in
            switch result {
            case .purchased:
                print("User purchased: \(plan?.name ?? "")")
                EMobi.shared.setSubscribedUser(isSubscribed: true)
                saveSubscriptionStatus(isSubscribed: EMobi.shared.isSubscribedUser())
                
                if EMobi.shared.getMMP() == MMP.adjust {
                    AdjustManager.shared.trackPurchaseEvent(purchaseToken: Constant.shared.adjustSubscriptionToken, productID: plan?.appleProductId ?? "", transactionID: "")
                }else if EMobi.shared.getMMP() == MMP.appsflyer {
                    AppsFlyersManager.shared.trackPurchaseEvent(productID: plan?.appleProductId ?? "", amount: plan?.amount as! Double  )
                }
                    
                break
            case .restored:
                print("User restored: \(plan?.name ?? "")")  
                EMobi.shared.setSubscribedUser(isSubscribed: true)
                saveSubscriptionStatus(isSubscribed: EMobi.shared.isSubscribedUser())
               // AdjustManager.shared.trackPurchaseEvent(purchaseToken: Constant.shared.adjustRestoreToken, productID: plan?.appleProductId ?? "", transactionID: "")
                  
                break
            case .cancelled:
                print("User cancelled: \(plan?.name ?? "")")
                guard let completionFailure else { return }
                completionFailure()
                break
            @unknown default:
                break
            }
        })
        
        completionSuccess(purhchasely)
        
    }
    
    func restoreAllProducts(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
 
        Purchasely.restoreAllProducts(success: {
            self.checkSubscription()
            success()
        }, failure: { (error) in
            failure(error) 
            // Display error
        })
        
    }

    func checkSubscription(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Purchasely.userSubscriptions(success: { (subscriptions) in
                if(subscriptions?.count ?? 0 > 0){
                    EMobi.shared.setSubscribedUser(isSubscribed: true)
                    saveSubscriptionStatus(isSubscribed: EMobi.shared.isSubscribedUser())
                }
            }, failure: { (error) in
                // Display error
            })
        }
    }
     
    func calculateDurationOfSubscription(duration: String) -> DurationUnit{
        
        if (duration == "weekly") {
            return .week
        }
        if (duration == "monthly") {
            return .month
        }
        if (duration == "annual"){
            return .year
        }
        
        return .unknown
    }
}
