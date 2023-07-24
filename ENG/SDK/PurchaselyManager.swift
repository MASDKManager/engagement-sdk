//
//  PurchaselyManager.swift
//  ENG
//
//  Created by Maarouf on 7/19/23.
//

import Foundation
import Purchasely
import StoreKit



enum PaywallType : String {
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
        Purchasely.start(withAPIKey: key, appUserId: user_uuid, runningMode: .full, eventDelegate: nil, logLevel: .debug) { success, err in
            if (success) {
                print("purchasely initiaisation: success")
            } else {
                print("purchasely initiaisation: failed")
            }
        }
         
    }
 
    
    func showPurchaselyPaywall(type: PaywallType = .paywall, completionSuccess: (() -> ())?, completionFailure: (() -> ())?)-> UIViewController? {
     
        guard firebaseRemoteConfigLoaded else {
            // In case Firebase Remote Config is not loaded, do nothing and return nil
            return nil
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
                AdjustManager.shared.trackPurchaseEvent(purchaseToken: Constant.shared.purchaseToken, productID: plan?.appleProductId ?? "", transactionID: "")
                 
               
                guard let completionSuccess else { return }
                completionSuccess()
                break
            case .restored:
                print("User restored: \(plan?.name ?? "")")  
                EMobi.shared.setSubscribedUser(isSubscribed: true)
                saveSubscriptionStatus(isSubscribed: EMobi.shared.isSubscribedUser())
                AdjustManager.shared.trackPurchaseEvent(purchaseToken: Constant.shared.restoreToken, productID: plan?.appleProductId ?? "", transactionID: "")
                 
                
                guard let completionSuccess else { return }
                completionSuccess()
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
          
        return purhchasely
        
    }
    
    func restoreAllProducts() {
        
        Purchasely.restoreAllProducts(success: {
            // Reload content and display a success / thank you message to user
        }, failure: { (error) in
            // Display error
        })
        
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

 
