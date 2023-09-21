//
//  AdjustManager.swift
//  ENG
//
//  Created by Maarouf on 7/19/23.
//

import Foundation
import AppsFlyerLib
import AppsFlyerAdRevenue
 
class AppsFlyersManager {
    static let shared = AppsFlyersManager()
    
    
    func trackPurchaseEvent( productID: String, amount : Double) {
        
        AppsFlyerLib.shared().logEvent(AFEventPurchase,
        withValues: [
            AFEventParamContentId: productID,
            AFEventParamContentType : "Purchase",
            AFEventParamRevenue: amount,
            AFEventParamCurrency:"USD"
        ]);
         
        print( tag + "trackPurchaseEvent sent init")
    }
    
    func sendConversionEvent(productID: String, amount : Double, eventData: [String: String]) {
        
//        if let swiftDictionary = nsDictionary as? [String: Int] {
//            
//        }
  
        AppsFlyerLib.shared().logEvent(AFEventPurchase,
        withValues: [
            AFEventParamContentId: productID,
            AFEventParamContentType : "Purchase",
            AFEventParamRevenue: amount,
            AFEventParamCurrency:"USD"
        ]);
    }
    
}
