//
//  AdjustManager.swift
//  ENG
//
//  Created by Maarouf on 7/19/23.
//

import Foundation
import Adjust
 
class AdjustManager {
    static let shared = AdjustManager()
    
    
    func trackPurchaseEvent(purchaseToken: String, productID: String, transactionID: String) {
        let event = ADJEvent(eventToken: Constant.shared.adjustSubscriptionToken)
        
        event?.addCallbackParameter("user_uuid", value: getUserID())
        event?.addCallbackParameter("inAppPurchaseTime", value: "\(Date())")
        event?.addCallbackParameter("inAppTransactionId", value: transactionID)
        event?.addCallbackParameter("inAppProductId", value: productID)
        
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            event?.addCallbackParameter("inAppPackageName", value: bundleIdentifier)
        } else {
            print("Unable to retrieve the bundle identifier.")
        }
        
        Adjust.trackEvent(event)
        
        print( tag + "trackPurchaseEvent sent init")
    }
    
    func sendConversionEvent( eventData: [String: String]) {
        let adjustEvent = ADJEvent(eventToken: Constant.shared.adjustConversionToken)
            
        for (key, value) in eventData {
            adjustEvent?.addCallbackParameter(key, value: value )
        }
        
        Adjust.trackEvent(adjustEvent)
    }
    
}
